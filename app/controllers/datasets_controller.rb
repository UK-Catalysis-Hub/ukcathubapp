class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show, :facets, :indicators, :top_researchers]
  before_action :normalize_dataset_sort_params, only: [:index, :facets]
  
  class DatasetSearch < FortyFacets::FacetSearch
    model 'Dataset' # which model to search for
    text :name, name: 'Data object name'  # filter by a generic string entered by the user
    facet :ds_type, name: 'Data object type', order: Proc.new { |ds_type| ds_type }
    facet :repository, name: 'Repository', order: Proc.new { |repository| repository }

    orders 'Name (A-Z)'          => { name: :asc },
       'Name (Z-A)'          => { name: :desc },
       'Date, newest first'  => "COALESCE(startdate, created_at) DESC",
       'Date, oldest first'  => "COALESCE(startdate, created_at) ASC"
  end

  # GET /datasets or /datasets.json
  def index
    page     = (params[:page].presence || 1).to_i
    per_page = [[(params[:per_page].presence || 10).to_i, 1].max, 100].min

    respond_to do |format|
      # ---- HTML: keep existing ERB working (search[name], facets, order) ----
      format.html do
        @search   = DatasetSearch.new(params[:search] || {})
        scope     = @search.result                # this version of FortyFacets uses `.result`
        @datasets = scope.paginate(page: page, per_page: per_page)
        render :index
      end

      # ---- JSON: API with q/repository/ds_type/date/year/order/pagination ----
      format.json do
        scope = Dataset.all

        if params[:q].present?
          q = "%#{params[:q].strip}%"
          scope = scope.where(
            "#{ilike('name')} OR #{ilike('description')} OR #{ilike('doi')} OR #{ilike('location')}",
            q: q
          )
        end

        ds_type = params[:data_type].presence || params[:ds_type].presence
        scope   = scope.where(ds_type: ds_type) if ds_type
        scope   = scope.where(repository: params[:repository]) if params[:repository].present?

        if params[:date_from].present?
          scope = scope.where("COALESCE(startdate, created_at) >= ?", params[:date_from])
        end
        if params[:date_to].present?
          scope = scope.where("COALESCE(startdate, created_at) <= ?", params[:date_to])
        end
        if params[:year].present?
          scope = scope.where("#{year_expr} = ?", params[:year].to_i) # DB-safe
        end

        scope = scope.order(dataset_order_clause(params[:order]))
        items = scope.paginate(page: page, per_page: per_page)

        render json: {
          data: items.map { |d|
            {
              id:          d.id,
              name:        d.name,
              description: d.description,
              date:        d.respond_to?(:startdate) ? d.startdate : d.created_at,
              doi:         d.try(:doi),
              location:    d.try(:location) || d.try(:url) || d.try(:link),
              repository:  d.try(:repository),
              data_type:   d.try(:ds_type)
            }
          },
          meta: {
            pagination: {
              page: page,
              per_page: per_page,
              total: scope.except(:offset, :limit).count
            },
            sort: (params[:order].presence || 'date_desc'),
            filters: {
              q: params[:q],
              repository: params[:repository],
              data_type: ds_type,
              date_from: params[:date_from],
              date_to: params[:date_to],
              year: params[:year]
            }
          }
        }
      end
    end
  end



  def facets
    base = Dataset.all

    if params[:q].present?
      q = "%#{params[:q].strip}%"
      base = base.where("name ILIKE :q OR description ILIKE :q OR doi ILIKE :q OR location ILIKE :q", q: q)
    end
    if params[:date_from].present?
      base = base.where("COALESCE(startdate, created_at) >= ?", params[:date_from])
    end
    if params[:date_to].present?
      base = base.where("COALESCE(startdate, created_at) <= ?", params[:date_to])
    end

    rel = base.reorder(nil)

    repo_counts = rel.group(:repository).count
    type_counts = rel.group(:ds_type).count
    year_sql    = year_expr # << DB-safe YEAR expression below
    year_counts = rel.group(Arel.sql(year_sql)).count

    render json: {
      data: {
        repository: {
          total_unique: rel.where.not(repository: [nil, ""]).distinct.count(:repository),
          options: repo_counts.keys.compact.sort,
          counts: repo_counts
        },
        data_type: {
          total_unique: rel.where.not(ds_type: [nil, ""]).distinct.count(:ds_type),
          options: type_counts.keys.compact.sort,
          counts: type_counts
        },
        year: {
          options: year_counts.keys.compact.map { |k| k.to_i }.sort.reverse,
          counts: year_counts.transform_keys { |k| k.to_i }
        }
      }
    }
  end

  def top_researchers
    limit  = (params[:limit].presence || 10).to_i.clamp(1, 100)

    base = Author
            .joins(article_authors: { article: :article_datasets })
            .joins("INNER JOIN datasets ON datasets.id = article_datasets.dataset_id")

    # Optional filters (match datasets list/indicators)
    ds_type = params[:data_type].presence || params[:ds_type].presence
    base    = base.where(datasets: { ds_type: ds_type }) if ds_type
    base    = base.where(datasets: { repository: params[:repository] }) if params[:repository].present?

    if params[:date_from].present?
      base = base.where("COALESCE(datasets.startdate, datasets.created_at) >= ?", params[:date_from])
    end
    if params[:date_to].present?
      base = base.where("COALESCE(datasets.startdate, datasets.created_at) <= ?", params[:date_to])
    end

    rows = base
            .select("authors.id AS author_id, COUNT(DISTINCT article_datasets.dataset_id) AS dataobjects_count")
            .group("authors.id")
            .order("dataobjects_count DESC, authors.id ASC")
            .limit(limit)

    author_ids    = rows.map { |r| r.read_attribute(:author_id) }

    # ⬅️ FIX: load full Author records (no explicit select list, so no unknown columns)
    authors_by_id = Author.where(id: author_ids).index_by(&:id)

    data = rows.map do |r|
      a = authors_by_id[r.read_attribute(:author_id)]
      {
        id:          (a&.id || r.read_attribute(:author_id)).to_i,
        full_name:   author_full_name(a),                               # uses helper below
        dataobjects: r.read_attribute(:dataobjects_count).to_i,
        orcid:       a.try(:orcid)
      }
    end

    render json: {
      data: data,
      meta: {
        limit: limit,
        filters: {
          repository: params[:repository],
          data_type:  ds_type,
          date_from:  params[:date_from],
          date_to:    params[:date_to]
        }
      }
    }

  end


  # app/controllers/datasets_controller.rb
  def indicators
    # --- filters (match /datasets index) ---
    base = Dataset.all

    if params[:q].present?
      q = "%#{params[:q].strip}%"
      base = base.where(
        "#{ilike('name')} OR #{ilike('description')} OR #{ilike('doi')} OR #{ilike('location')}",
        q: q
      )
    end

    ds_type = params[:data_type].presence || params[:ds_type].presence
    base    = base.where(ds_type: ds_type) if ds_type
    base    = base.where(repository: params[:repository]) if params[:repository].present?

    if params[:date_from].present?
      base = base.where("COALESCE(startdate, created_at) >= ?", params[:date_from])
    end
    if params[:date_to].present?
      base = base.where("COALESCE(startdate, created_at) <= ?", params[:date_to])
    end

    rel = base.reorder(nil) # drop any default ORDER for clean GROUP BYs

    # --- per year + cumulative ---
    year_counts_h = rel.group(Arel.sql(year_expr)).count # { "2020"=>n, ... } adapter-safe
    years         = year_counts_h.keys.compact.map(&:to_i).sort
    per_year      = years.map { |y| year_counts_h[y.to_s] || year_counts_h[y] || 0 }
    cumulative    = []
    running = 0
    per_year.each { |c| running += c; cumulative << running }

    # --- repositories table + summary + buckets ---
    repo_counts_h = rel.group(:repository).count # { "https://repo" => n, nil=>m }
    # strip nil/blank from table; indicators page typically shows real hosts
    repo_counts   = repo_counts_h.reject { |k,_| k.blank? }.sort_by { |(_k,v)| -v }

    values        = repo_counts.map(&:last)
    repo_summary  = {
      repositories: values.size,
      average:      values.empty? ? 0.0 : (values.sum.to_f / values.size).round(2),
      maximum:      values.max || 0,
      minimum:      values.min || 0
    }

    # Buckets like in the UI: 1–5, 6–10, 11–15, >20 (based on counts per repository)
    buckets = { "1-5" => 0, "6-10" => 0, "11-15" => 0, "more than 20" => 0 }
    values.each do |n|
      case n
      when 1..5   then buckets["1-5"] += 1
      when 6..10  then buckets["6-10"] += 1
      when 11..15 then buckets["11-15"] += 1
      else            buckets["more than 20"] += 1 if n > 20
      end
    end

    raw_type_counts = rel.group(:ds_type).count # { "Document (Portable document [pdf])" => 589, ... }

    group_counts = Hash.new(0)
    raw_type_counts.each do |raw_type, count|
      label = group_label_for_ds_type(raw_type)
      group_counts[label] += count
    end

    # Ensure all groups appear (even if zero), and keep the specified order
    groups_table  = DATAOBJECT_GROUPS.map { |label| { group: label, count: group_counts[label] || 0 } }
    groups_labels = DATAOBJECT_GROUPS
    groups_counts = DATAOBJECT_GROUPS.map { |label| group_counts[label] || 0 }

    # --- recent items (latest 10 by date) ---
    recent_limit = (params[:recent].presence || 10).to_i
    recent_items = base.order(Arel.sql("COALESCE(startdate, created_at) DESC"))
                      .limit(recent_limit)
                      .pluck(:id, :name, :description, :startdate, :created_at, :doi, :location, :repository, :ds_type)
                      .map do |id, name, desc, startdate, created_at, doi, loc, repo, dtype|
      dt = startdate || created_at
      {
        id: id,
        name: name,
        description: desc,
        date: dt,
        year: dt&.year,
        doi: doi,
        location: loc,
        repository: repo,
        data_type: dtype
      }
    end

    render json: {
      data: {
        years: {
          labels: years,          # [2013, 2014, ...]
          counts: per_year,       # per year
          cumulative: cumulative  # running total
        },
        repositories: {
          table: repo_counts.map { |rep,count| { repository: rep, count: count } }, # sorted desc
          summary: repo_summary,
          buckets: buckets
        },
        groups: {
          table: groups_table.map { |name, count| { group: name, count: count } },
          donut: { labels: groups_labels, counts: groups_counts }
        },
        recent: recent_items
      },
      meta: {
        filters: {
          q: params[:q],
          repository: params[:repository],
          data_type: ds_type,
          date_from: params[:date_from],
          date_to: params[:date_to]
        }
      }
    }
  end



  # GET /datasets/:id (HTML) or /api/v1/datasets/:id (JSON)
  def show
    respond_to do |format|
      format.html
      format.json do
        render json: {
          data: {
            id:          @dataset.id,
            name:        @dataset.name,
            description: @dataset.description,
            date:        (@dataset.respond_to?(:startdate) ? @dataset.startdate : @dataset.created_at),
            doi:         @dataset.try(:doi),
            location:    @dataset.try(:location) || @dataset.try(:url) || @dataset.try(:link),
            repository:  @dataset.try(:repository),
            data_type:   @dataset.try(:ds_type)
          }
        }
      end
    end
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/1/edit
  def edit
  end

  # POST /datasets or /datasets.json
  def create
    @dataset = Dataset.new(dataset_params)

    respond_to do |format|
      if @dataset.save
        format.html { redirect_to dataset_url(@dataset), notice: "Dataset was successfully created." }
        format.json { render :show, status: :created, location: @dataset }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /datasets/1 or /datasets/1.json
  def update
    respond_to do |format|
      if @dataset.update(dataset_params)
        format.html { redirect_to dataset_url(@dataset), notice: "Dataset was successfully updated." }
        format.json { render :show, status: :ok, location: @dataset }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /datasets/1 or /datasets/1.json
  def destroy
    @dataset.destroy!

    respond_to do |format|
      format.html { redirect_to datasets_url, notice: "Dataset was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  # download datasets stats
  def data_count
    do_by_year = Dataset.ds_per_year
    doby = do_by_year.each.collect{ |doby| [doby['item'], doby['i_count']]}
    theme_csv = get_csv(['year','count'], doby)
    send_data(theme_csv, 
              :type => 'text/plain', :disposition => 'attachment', :filename => 'ukch_dataobject_count.csv')
  end 

  # upload new data objects (csv)
  def upload_data
    csv_file = params[:file]
    @data_rows = CSV.read(csv_file.path)
    @data_rows.each do |do_row|
      if do_row[3] != 'description' and do_row[7] != 'title'
        ds_id = do_row[5]
        @dor = Dataset.find_by(location: ds_id)
        art_id = do_row[1]
        art_doi = do_row[2]
        # add new do record
        if @dor == nil
          @dor = Dataset.new()
          @dor.description = do_row[3]
          @dor.doi = do_row[4]
          @dor.location = do_row[6]
          @dor.name = do_row[7]
          @dor.startdate = do_row[8]
          @dor.ds_type = do_row[9]
          @dor.repository = do_row[10]
          @dor.save()
        end
        # add article_dataset_link
        if @dor.id > 1
          @art_ds_link = ArticleDataset.find_by(article_id: art_id,
                                                dataset_id: @dor.id)
          if @art_ds_link == nil
            @art_ds_link = ArticleDataset.new()
            @art_ds_link.doi = art_doi
            @art_ds_link.article_id = art_id
            @art_ds_link.dataset_id = @dor.id
            @art_ds_link.save()
          else
            puts "article-do link record exists"
          end
        end
      end
    end
    respond_to do |format|
      flash[:notice] = 'upload process started ' + @data_rows.length().to_s() + " entries "
      format.html { redirect_to action: "index" }
      format.json { head :no_content }
    end
  end 


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dataset
      @dataset = Dataset.find(params[:id])
    end

    def normalize_dataset_sort_params
      params[:order] ||= params[:sort] if params[:sort].present?
      params[:order] ||= 'date_desc'
    end

    def dataset_order_clause(order)
      case order
      when 'name_asc'  then { name: :asc }
      when 'name_desc' then { name: :desc }
      when 'repo_asc'  then { repository: :asc }
      when 'repo_desc' then { repository: :desc }
      when 'date_asc'  then Arel.sql('COALESCE(startdate, created_at) ASC')
      else                   Arel.sql('COALESCE(startdate, created_at) DESC') # date_desc (default)
      end
    end
    
    def db_adapter
      ActiveRecord::Base.connection.adapter_name.downcase
    end

    # Returns a SQL snippet that extracts the YEAR from COALESCE(startdate, created_at)
    def year_expr
      col = "COALESCE(startdate, created_at)"
      case db_adapter
      when /sqlite/
        "CAST(strftime('%Y', #{col}) AS INTEGER)"         # SQLite
      when /postgres/
        "EXTRACT(YEAR FROM #{col})::int"                  # Postgres
      when /mysql/
        "YEAR(#{col})"                                    # MySQL/MariaDB
      else
        "EXTRACT(YEAR FROM #{col})"                       # Fallback
      end
    end

    def ilike(column)
      if db_adapter =~ /postgres/
        "#{column} ILIKE :q"
      else
        "LOWER(#{column}) LIKE LOWER(:q)" # SQLite/MySQL compatible
      end
    end
    DATAOBJECT_GROUPS = [
      'Compressed file [zip]',
      'Crystal structure [cif/pdbe]',
      'Dataset',
      'Document [pdf/html/docx/ppt]',
      'Media File (image/video)',
      'Software [app/api/service/source code]',
      'xyz'
    ].freeze

    def group_label_for_ds_type(ds_type)
      s = ds_type.to_s.downcase

      return 'Compressed file [zip]' if s.include?('zip') || s.include?('compressed')
      return 'Crystal structure [cif/pdbe]' if s.include?('crystal') || s.include?('cif') || s.include?('pdbe')
      return 'Dataset' if s == 'dataset' || s.include?('dataset')
      return 'Document [pdf/html/docx/ppt]' if s.include?('document') || s.match?(/\b(pdf|html|docx?|pptx?)\b/)
      return 'Media File (image/video)' if s.include?('image') || s.include?('video') || s.include?('media')
      return 'Software [app/api/service/source code]' if s.include?('software') || s.include?('source code') ||
                                                        s.include?('api') || s.include?('service') ||
                                                        s.include?('app') || s.include?('code')
      'xyz'
    end

    # Build a human name from whatever columns exist on Author
    def display_author_name(author)
      return "Unknown author" if author.nil?

      # Common patterns across schemas
      return author.name if author.respond_to?(:name) && author.name.present?

      given  = if author.respond_to?(:given) && author.given.present?
                author.given
              elsif author.respond_to?(:first_name) && author.first_name.present?
                author.first_name
              end

      family = if author.respond_to?(:family) && author.family.present?
                author.family
              elsif author.respond_to?(:last_name) && author.last_name.present?
                author.last_name
              end

      if given.present? || family.present?
        [given, family].compact.join(' ')
      elsif author.respond_to?(:short) && author.short.present?
        author.short
      else
        "Author ##{author.id}"
      end
    end

    def author_full_name(author)
      return "Unknown author" if author.nil?

      # Single-field display options first
      %i[name display_name full_name short short_name].each do |attr|
        v = author.try(attr)
        return v.strip if v.is_a?(String) && v.strip.present?
      end

      # Combine common first/given & last/family variants
      given = %i[given given_name first_name firstname first forename forenames]
                .map { |a| author.try(a) }.find { |v| v.present? }
      family = %i[family family_name last_name lastname last surname surnames]
                .map { |a| author.try(a) }.find { |v| v.present? }

      if given || family
        return [given, family].compact.map(&:to_s).map(&:strip).reject(&:empty?).join(' ')
      end

      # Fallback: latest ArticleAuthor row (often stores names)
      if defined?(ArticleAuthor)
        aa = ArticleAuthor.where(author_id: author.id).order(id: :desc).limit(1).first
        if aa
          %i[name author_name full_name display_name].each do |attr|
            v = aa.try(attr)
            return v.strip if v.is_a?(String) && v.strip.present?
          end
          given2  = %i[given given_name first_name firstname first forename].map { |a| aa.try(a) }.find { |v| v.present? }
          family2 = %i[family family_name last_name lastname last surname].map { |a| aa.try(a) }.find { |v| v.present? }
          return [given2, family2].compact.map(&:to_s).map(&:strip).reject(&:empty?).join(' ') if (given2 || family2)
        end
      end

      "Author ##{author.id}"
    end




    # Only allow a list of trusted parameters through.
    def dataset_params
      params.require(:dataset).permit(:complete, :description, :doi, :enddate, :location, :name, :startdate, :ds_type, :repository)
    end
end
