class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update, :destroy, :articles]
  before_action :authenticate_user!, except: [:index, :show, :articles, :indicators]

  # ---- FortyFacets search (kept for HTML views) ----
  class AuthorsSearch < FortyFacets::FacetSearch
    model 'Author'
    text  :last_name
    facet :given_name, name: 'Given Name'
    facet :last_name,  name: 'Last Name'

    orders 'Name (A-Z)'    => { last_name: :asc, given_name: :asc },
           'Name (Z-A)'    => { last_name: :desc, given_name: :desc },
           'ORCID (A-Z)'   => "orcid asc",
           'ORCID (Z-A)'   => { orcid: :desc }
  end
  PI_IDS = [11, 15, 23, 22, 99, 111, 120, 134, 154, 171, 329].freeze
  # GET /authors
  # GET /authors.json
  def index
    @search = AuthorsSearch.new(params)

    if user_signed_in?
      # HTML flow (unchanged)
      @authors = @search.result.paginate(page: params[:page], per_page: 10)
    else
      # Public HTML shows only consenting authors
      @authors = @search.result.isap.paginate(page: params[:page], per_page: 10)
    end

    respond_to do |format|
      format.html # existing templates

      # JSON API for React
      format.json do
        page     = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i

        # ---- Sorting options you asked for ----
        # Accepts: "last_name asc" | "last_name desc" | "orcid asc" | "orcid desc"
        # Default: last_name asc
        sort_param = params[:sort].to_s.downcase.strip
        allowed_sorts = {
          "last_name asc"  => "LOWER(authors.last_name) ASC, LOWER(authors.given_name) ASC",
          "last_name desc" => "LOWER(authors.last_name) DESC, LOWER(authors.given_name) DESC",
          "orcid asc"      => "COALESCE(authors.orcid,'') ASC, LOWER(authors.last_name) ASC",
          "orcid desc"     => "COALESCE(authors.orcid,'') DESC, LOWER(authors.last_name) ASC"
        }
        order_clause = allowed_sorts[sort_param].presence || allowed_sorts["last_name asc"]

        # Base query: all authors if signed in; only consenting (isap) if public
        base = user_signed_in? ? Author.all : Author.isap

        # Count each author's publications via LEFT JOIN on article_authors
        base = base.left_joins(:article_authors)
                   .group("authors.id")
                   .select("authors.*, COUNT(article_authors.id) AS articles_count")

        # Search by last_name (case-insensitive)
        if params.dig(:search, :last_name).present?
          term = params[:search][:last_name].to_s.strip.downcase
          base = base.where("LOWER(authors.last_name) LIKE ?", "%#{term}%")
        end

        # Apply sorting
        ordered = base.order(Arel.sql(order_clause))

        # --- SQLite-safe group counting: drop ORDER BY before count ---
        grouped_counts_hash = ordered.reorder(nil).count(:id) # => {author_id => count, ...}
        total               = grouped_counts_hash.length
        total_pages         = (total / per_page.to_f).ceil

        # Page slice
        authors_pg = ordered.offset((page - 1) * per_page).limit(per_page)

        # Header counters
        total_authors      = Author.count
        consenting_authors = Author.isap.count

        render json: {
          data: authors_pg.map { |a|
            {
              id: a.id,
              given_name: a.given_name,
              last_name: a.last_name,
              name: [a.last_name, a.given_name].compact.join(", "),
              orcid: a.orcid,
              orcid_url: (a.orcid.present? ? "https://orcid.org/#{a.orcid.to_s.sub(%r{https?://orcid\.org/}, '')}" : nil),
              articles_count: a.read_attribute(:articles_count).to_i
            }
          },
          meta: {
            pagination: { page: page, per_page: per_page, pages: total_pages, total: total },
            counts:     { consenting: consenting_authors, total: total_authors },
            sort:       sort_param.presence || "last_name asc"
          }
        }
      end
    end
  end

  # GET /authors/1
  # GET /authors/1.json
  def show
    @aut_articles = @author.articles.active

    respond_to do |format|
      format.html
      format.json do
        render json: {
          data: {
            id: @author.id,
            given_name: @author.given_name,
            last_name: @author.last_name,
            name: [@author.last_name, @author.given_name].compact.join(", "),
            orcid: @author.orcid,
            orcid_url: (@author.orcid.present? ? "https://orcid.org/#{@author.orcid.to_s.sub(%r{https?://orcid\.org/}, '')}" : nil),
            articles_count: @author.article_authors.count
          }
        }
      end
    end
  end

  # Optional drill-down: GET /api/v1/authors/:id/articles
  def articles
    page     = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    # Sorting for articles list (independent of the main index sort)
    # Accepts: "pub_year asc|desc", "title asc|desc" (default pub_year desc)
    sort_param = params[:sort].to_s.downcase.strip
    allowed_article_sorts = {
      "pub_year asc"  => "pub_year ASC",
      "pub_year desc" => "pub_year DESC",
      "title asc"     => "title ASC",
      "title desc"    => "title DESC"
    }
    order_clause = allowed_article_sorts[sort_param].presence || allowed_article_sorts["pub_year desc"]

    scope = @author.articles.active.order(Arel.sql(order_clause))
    total = scope.count
    total_pages = (total / per_page.to_f).ceil
    list = scope.offset((page - 1) * per_page).limit(per_page)

    render json: {
      data: list.as_json(only: [:id, :title, :doi, :pub_year, :container_title, :publisher]),
      meta: { pagination: { page: page, per_page: per_page, pages: total_pages, total: total }, sort: sort_param.presence || "pub_year desc" }
    }
  end

  # ---- Standard CRUD (unchanged) ----
  def new
    @author = Author.new
  end

  def edit; end

  def create
    @author = Author.new(author_params)
    respond_to do |format|
      if @author.save
        format.html { redirect_to author_url(@author), notice: "Author was successfully created." }
        format.json { render :show, status: :created, location: @author }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @author.update(author_params)
        format.html { redirect_to author_url(@author), notice: "Author was successfully updated." }
        format.json { render :show, status: :ok, location: @author }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @author.destroy!
    respond_to do |format|
      format.html { redirect_to authors_url, notice: "Author was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def indicators
  limit = (params[:limit] || 10).to_i

  # Consent scope:
  # - public users: only consenting authors (isap)
  # - signed-in users: all authors
  authors_base = user_signed_in? ? Author.all : Author.isap

  # Counts to report explicitly
  authors_count_total     = Author.count
  authors_count_permitted = Author.isap.count
  authors_count_used      = authors_base.count
  consent_scope           = user_signed_in? ? "all" : "isap"

  # PI list from legacy app (exclude for non-PI leaderboard)
  pi_ids = [11, 15, 23, 22, 99, 111, 120, 134, 154, 171, 329]

  # ---------- Publications per author (active articles only) ----------
  pubs_rel = authors_base
    .joins(:article_authors)
    .joins("INNER JOIN articles ON articles.id = article_authors.article_id")
    .where("articles.status = 'Added'")
    .group("authors.id")

  pubs_counts = pubs_rel.reorder(nil).count("articles.id")  # { author_id => pubs }
  sum_pubs    = pubs_counts.values.sum
  avg_pubs    = authors_count_used.zero? ? 0.0 : (sum_pubs.to_f / authors_count_used).round(2)
  max_pubs    = pubs_counts.values.max || 0
  min_pubs    = pubs_counts.values.min || 0

  buckets = { "1-5" => 0, "6-10" => 0, "11-15" => 0, "16-20" => 0, "more than 20" => 0 }
  pubs_counts.values.each do |c|
    case c
    when 1..5   then buckets["1-5"] += 1
    when 6..10  then buckets["6-10"] += 1
    when 11..15 then buckets["11-15"] += 1
    when 16..20 then buckets["16-20"] += 1
    else buckets["more than 20"] += 1 if c > 20
    end
  end

  # ---------- Top publishing (all) ----------
  top_publishers = authors_base
    .joins(:article_authors)
    .joins("INNER JOIN articles ON articles.id = article_authors.article_id")
    .where("articles.status = 'Added'")
    .group("authors.id")
    .select("authors.*, COUNT(articles.id) AS publications_count")
    .order(Arel.sql("publications_count DESC, LOWER(authors.last_name) ASC"))
    .limit(limit)

  # ---------- Top publishing (non-PI) ----------
  top_publishers_non_pi = authors_base
    .where.not(id: pi_ids)
    .joins(:article_authors)
    .joins("INNER JOIN articles ON articles.id = article_authors.article_id")
    .where("articles.status = 'Added'")
    .group("authors.id")
    .select("authors.*, COUNT(articles.id) AS publications_count")
    .order(Arel.sql("publications_count DESC, LOWER(authors.last_name) ASC"))
    .limit(limit)

  # ---------- Most cited ----------
  most_cited = authors_base
    .joins(:article_authors)
    .joins("INNER JOIN articles ON articles.id = article_authors.article_id")
    .where("articles.status = 'Added'")
    .group("authors.id")
    .select("authors.*, COALESCE(SUM(articles.referenced_by_count), 0) AS citations_total")
    .order(Arel.sql("citations_total DESC, LOWER(authors.last_name) ASC"))
    .limit(limit)

  # ---------- Top data-publishing ----------
  data_publishers = authors_base
    .joins(:article_authors)
    .joins("INNER JOIN articles ON articles.id = article_authors.article_id")
    .joins("INNER JOIN article_datasets ON article_datasets.article_id = articles.id")
    .where("articles.status = 'Added'")
    .group("authors.id")
    .select("authors.*, COUNT(article_datasets.id) AS data_objects_count")
    .order(Arel.sql("data_objects_count DESC, LOWER(authors.last_name) ASC"))
    .limit(limit)

  # ---------- Countries (from author_affiliations.country) ----------
  country_counts = authors_base
    .joins(:author_affiliations)
    .group("author_affiliations.country")
    .reorder(nil)
    .count("*")

  render json: {
    data: {
      scope: {
        consent_scope: consent_scope,                 # "isap" or "all"
        authors_count_used: authors_count_used,       # used in all calculations above
        authors_count_permitted: authors_count_permitted,  # isap total
        authors_count_total: authors_count_total           # absolute total
      },
      publications_per_author: {
        summary: { authors: authors_count_used, average: avg_pubs, maximum: max_pubs, minimum: min_pubs },
        buckets: buckets
      },
      top_publishers: top_publishers.map { |a|
        { id: a.id, name: [a.last_name, a.given_name].compact.join(", "),
          orcid: a.orcid, publications: a.read_attribute(:publications_count).to_i }
      },
      top_publishers_non_pi: top_publishers_non_pi.map { |a|
        { id: a.id, name: [a.last_name, a.given_name].compact.join(", "),
          orcid: a.orcid, publications: a.read_attribute(:publications_count).to_i }
      },
      most_cited: most_cited.map { |a|
        { id: a.id, name: [a.last_name, a.given_name].compact.join(", "),
          orcid: a.orcid, citations: a.read_attribute(:citations_total).to_i }
      },
      data_publishers: data_publishers.map { |a|
        { id: a.id, name: [a.last_name, a.given_name].compact.join(", "),
          orcid: a.orcid, data_objects: a.read_attribute(:data_objects_count).to_i }
      },
      countries: country_counts
    }
  }
end

  private

    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:last_name, :given_name, :orcid, :isap)
    end
end
