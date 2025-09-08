# app/controllers/api/v1/dashboard_controller.rb
module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_user!, except: [:overview]

      # GET /api/v1/dashboard
      # Optional params:
      #   recent_articles: Integer (default 5)
      #   top_data_researchers: Integer (default 10)
      def overview
        recent_n = (params[:recent_articles].presence || 5).to_i.clamp(1, 25)
        top_n    = (params[:top_data_researchers].presence || 10).to_i.clamp(1, 50)

        # ---- Stats cards -----------------------------------------------------
        totals = {
          articles:      Article.count,
          authors:       Author.count,
          institutions:  Organisation.count,
          data_objects:  Dataset.count
        }

        # ---- Publications: per year + cumulative + recent -------------------
        pubs_by_year_h = Article.where.not(pub_year: nil)
                                .group(:pub_year)
                                .order(pub_year: :asc)
                                .count
        pub_year_labels = pubs_by_year_h.keys
        pub_year_counts = pubs_by_year_h.values
        pub_cumulative  = pub_year_counts.each_with_object([]) { |n, a| a << n + (a.last || 0) }

        recent_articles = Article.active
                                 .includes(:themes)
                                 .order(pub_year: :desc, title: :asc)
                                 .limit(recent_n)
        recent = recent_articles.map do |a|
          {
            id: a.id,
            title: a.title,
            pub_year: a.pub_year,
            doi: a.doi,
            themes: a.themes.map { |t| { id: t.id, name: t.name } }
          }
        end

        # ---- Institutions: counts per country -------------------------------
        ctry_counts = Organisation.group(:country).count
        ctry_options = ctry_counts.keys.compact.sort

        # ---- Themes: per phase summary (labels + counts) --------------------
        theme_article_counts = Article.joins(:article_themes)
                                      .group('article_themes.theme_id')
                                      .count
        theme_records = Theme.where(id: theme_article_counts.keys).order(:name)
        summary_by_phase = {}
        theme_records.group_by(&:phase).each do |phase, items|
          labels = items.map(&:name)
          counts = items.map { |t| theme_article_counts[t.id] || 0 }
          summary_by_phase[phase] = { labels: labels, counts: counts, total: counts.sum }
        end
        phases = summary_by_phase.keys.sort

        # ---- Data objects: per year + cumulative ----------------------------
        ds_year_h = Dataset.group(Arel.sql(year_expr('COALESCE(startdate, created_at)'))).count
        ds_years  = ds_year_h.keys.compact.map(&:to_i).sort
        ds_counts = ds_years.map { |y| ds_year_h[y] || ds_year_h[y.to_s] || 0 }
        ds_cum    = ds_counts.each_with_object([]) { |n, a| a << n + (a.last || 0) }

        # ---- Top data publishing researchers --------------------------------
        rows = Author
                 .joins(article_authors: { article: :article_datasets })
                 .joins("INNER JOIN datasets ON datasets.id = article_datasets.dataset_id")
                 .select("authors.id AS author_id, COUNT(DISTINCT article_datasets.dataset_id) AS dataobjects_count")
                 .group("authors.id")
                 .order("dataobjects_count DESC, authors.id ASC")
                 .limit(top_n)
        author_ids    = rows.map { |r| r.read_attribute(:author_id) }
        authors_by_id = Author.where(id: author_ids).index_by(&:id)

        top_data_researchers = rows.map do |r|
          a = authors_by_id[r.read_attribute(:author_id)]
          {
            id: (a&.id || r.read_attribute(:author_id)).to_i,
            full_name: author_full_name(a),
            dataobjects: r.read_attribute(:dataobjects_count).to_i,
            orcid: a.try(:orcid)
          }
        end

        render json: {
          data: {
            stats: totals,
            publications: {
              years: { labels: pub_year_labels, counts: pub_year_counts, cumulative: pub_cumulative },
              recent: recent
            },
            themes: {
              phases: phases,
              summary_by_phase: summary_by_phase
            },
            institutions: {
              country: { options: ctry_options, counts: ctry_counts }
            },
            data_objects: {
              years: { labels: ds_years, counts: ds_counts, cumulative: ds_cum },
              top_researchers: top_data_researchers
            }
          }
        }
      end

      private

      def db_adapter
        ActiveRecord::Base.connection.adapter_name.downcase
      end

      # DB-safe year extraction for SQLite/Postgres/MySQL
      def year_expr(col_sql)
        case db_adapter
        when /sqlite/   then "CAST(strftime('%Y', #{col_sql}) AS INTEGER)"
        when /postgres/ then "EXTRACT(YEAR FROM #{col_sql})::int"
        when /mysql/    then "YEAR(#{col_sql})"
        else                 "EXTRACT(YEAR FROM #{col_sql})"
        end
      end

      # Build a robust full name from whatever columns exist; fallback to ArticleAuthor
      def author_full_name(author)
        return "Unknown author" if author.nil?

        %i[name display_name full_name short short_name].each do |attr|
          v = author.try(attr)
          return v.strip if v.is_a?(String) && v.strip.present?
        end

        given  = %i[given given_name first_name firstname first forename forenames]
                   .map { |a| author.try(a) }.find { |v| v.present? }
        family = %i[family family_name last_name lastname last surname surnames]
                   .map { |a| author.try(a) }.find { |v| v.present? }
        return [given, family].compact.map(&:to_s).map(&:strip).reject(&:empty?).join(' ') if given || family

        if defined?(ArticleAuthor)
          aa = ArticleAuthor.where(author_id: author.id).order(id: :desc).limit(1).first
          if aa
            %i[name author_name full_name display_name].each do |attr|
              v = aa.try(attr)
              return v.strip if v.is_a?(String) && v.strip.present?
            end
            g2 = %i[given given_name first_name firstname first forename].map { |a| aa.try(a) }.find { |v| v.present? }
            f2 = %i[family family_name last_name lastname last surname].map { |a| aa.try(a) }.find { |v| v.present? }
            return [g2, f2].compact.map(&:to_s).map(&:strip).reject(&:empty?).join(' ') if g2 || f2
          end
        end

        "Author ##{author.id}"
      end
    end
  end
end
