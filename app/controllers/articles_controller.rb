class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show, :bib_query, :arts_by_year_stats, :facets]

  class ArticleSearch < FortyFacets::FacetSearch
    model 'Article' # which model to search for
    scope :active   # only return articles which are in the scope 'active'
    text  :title    # filter by a generic string entered by the user

    facet :pub_year,        name: 'Year',     order: Proc.new { |pub_year| -pub_year }
    facet :container_title, name: 'Journal',  order: Proc.new { |container_title| container_title }
    facet :publisher,       name: 'Publisher',order: Proc.new { |publisher| publisher }

    orders 'Title (A-Z)'           => :title,
           'Title desc. (Z-A)'     => "title desc",
           'Year, newest first'    => "pub_year desc",
           'Year, oldest first'    => { pub_year: :asc, title: :asc }
  end

  # GET /articles or /articles.json
  def index
    @search   = ArticleSearch.new(params)
    scope     = @search.result.active.includes(:themes)   # <-- add includes(:themes)
    @articles = scope.paginate(page: params[:page], per_page: 10)

    respond_to do |format|
      format.html  # existing HTML view unchanged
      format.json do
        render json: {
          data: @articles.map { |a| serialize_article(a) },   # <-- send themes too
          meta: {
            pagination: {
              page: (params[:page].presence || 1).to_i,
              per_page: 10,
              total: scope.count
            }
          }
        }
      end
    end
  end


  # GET /articles/1 or /articles/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: { data: serialize_article(@article, include_abstract: true) } }
    end
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
    session[:return_to] = request.referer
  end

  # POST /articles or /articles.json
  def create
    @article = Article.new(article_params)
    respond_to do |format|
      if @article.save
        format.html { redirect_to article_url(@article), notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to article_url(@article), notice: "Article was successfully updated." }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!
    respond_to do |format|
      format.html { redirect_to articles_url, notice: "Article was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # VERIFY records in CR
  def verify
    VerifyCrossrefWorkerJob.perform_async
    respond_to do |format|
      flash[:notice] = 'verify process started'
      format.html { redirect_to action: "index" }
      format.json { head :no_content }
    end
  end

  # Upload CSV articles list
  def upload_csv
    csv_file = params[:file]
    @pub_rows = CSV.read(csv_file.path)
    @pub_rows.each do |pub_row|
      if pub_row[4] != 'doi' && pub_row[10] != nil
        p_doi = pub_row[4]
        p_themes = JSON.load(pub_row[10])

        @art = Article.find_by(doi: p_doi)
        if @art.nil?
          @art = Article.new()
          @art.doi = p_doi
          getPubData(@art, @art.doi)
          @art.container_title ||= pub_row[15]
          @art.save()

          p_themes.each do |theme_id|
            full_theme = Theme.find(theme_id)
            article_theme = ArticleTheme.new()
            article_theme.doi = @art.doi
            article_theme.theme_id = theme_id
            article_theme.project_year = @art.pub_year
            article_theme.article_id = @art.id
            article_theme.phase = full_theme.phase
            article_theme.save()
          end
        else
          # already present
        end

        if pub_row[4].to_i > 12
          break
        end
      end
    end

    respond_to do |format|
      flash[:notice] = 'upload process started ' + @pub_rows.length().to_s() + " entries "
      format.html { redirect_to action: "index" }
      format.json { head :no_content }
    end
  end

  # return publications as bib json data
  def bib_query
    articles = Article.active.all
    if params.key?('year') && params.key?('theme')
      articles = Article.active.where(pub_year: params[:year]).joins(:themes).where(themes: { short: params[:theme] })
    elsif params.key?('year')
      articles = Article.active.where(pub_year: params[:year])
    elsif params.key?('theme')
      articles = Article.active.joins(:themes).where(themes: { short: params[:theme] })
    end
    bib_data = get_bib_data(articles)
    respond_to do |format|
      format.json { render json: bib_data }
    end
  end

  # download publication stats
  def arts_by_year_stats
    arts_by_year = Article.where(status: "Added").group(:pub_year).count.collect { |pb| [pb[0], pb[1]] }
    arts_by_year_csv = get_csv(['year','count'], arts_by_year)
    send_data(arts_by_year_csv,
              type: 'text/plain', disposition: 'attachment', filename: 'ukch_pub_stats.csv')
  end

  def facets
    # Use the exact same search pipeline as index so results match
    search = ArticleSearch.new(params)
    scope  = search.result.active

    # Facet options + counts computed on the FILTERED scope
    years_counts = scope.group(:pub_year)
                        .order(pub_year: :desc)
                        .count
                        .reject { |k, _| k.nil? }

    journals_counts = scope.where.not(container_title: [nil, ""])
                          .group(:container_title)
                          .order(:container_title)
                          .count

    publishers_counts = scope.where.not(publisher: [nil, ""])
                            .group(:publisher)
                            .order(:publisher)
                            .count

    # Optional: pagination meta matching your list (per_page = 10 like index)
    total     = scope.count
    per_page  = (params[:per_page] || 10).to_i
    page      = (params[:page] || 1).to_i
    total_pages = (total / per_page.to_f).ceil

    render json: {
      data: {
        totals: { articles: total },
        pagination: { page: page, per_page: per_page, pages: total_pages },
        facets: {
          pub_year: {
            total_unique: years_counts.size,
            options: years_counts.keys,
            counts: years_counts
          },
          container_title: {
            total_unique: journals_counts.size,
            options: journals_counts.keys,
            counts: journals_counts
          },
          publisher: {
            total_unique: publishers_counts.size,
            options: publishers_counts.keys,
            counts: publishers_counts
          }
        }
      }
    }
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.includes(:themes).find(params[:id])   # <-- includes(:themes)
      @authors = @article.article_authors

      if @article.title.nil?
        @art = Article.find_by(doi: @article.doi)
        if @art.title.nil?
          @article = getPubData(@article, @article.doi)
          @article.save()
        else
          @article = @art
        end
      end

      if @article.article_authors.count == 0 || @article.article_authors[0].last_name.nil?
        getAutData(@authors, @article.doi, @article.id)
      end

      if @article.pub_year.nil?
        @article.pub_ol_year != nil ? @article.pub_year = @article.pub_ol_year : @article.pub_year = @article.pub_print_year
        @article.save()
      end
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(
        :doi, :title, :pub_year, :pub_type, :publisher, :container_title,
        :volume, :issue, :page, :pub_print_year, :pub_print_month, :pub_print_day,
        :pub_ol_year, :pub_ol_month, :pub_ol_day, :license, :referenced_by_count,
        :link, :url, :abstract, :status, :comment, :references_count, :journal_issue,
        :graphic_abstract
      )
    end

    # get list of publications as bibliography
    def get_bib_data(articles)
      bib_list = []
      articles.each do |article|
        author_list = article.authors.all
        disp_names = ""
        author_list.each do |auth|
          pr_name = auth.given_name.unicode_normalize(:nfd).gsub(/\p{M}/, '')
          pr_name = pr_name.gsub(/\w+/){ |s| "#{s[0].upcase}. " }
                           .sub(/\w+\z/, &:capitalize)
                           .gsub(' .',' ')
          this_name = pr_name + auth.last_name
          disp_names = disp_names.empty? ? this_name : "#{disp_names}, #{this_name}"
        end
        bib_list.append({
          "title"     => article.title,
          "year"      => article.pub_year,
          "authors"   => disp_names,
          "publisher" => article.container_title,
          "doi"       => article.doi,
          "pub_type"  => article.pub_type,
          "volume"    => article.volume,
          "issue"     => article.issue,
          "page"      => article.page
        })
      end
      bib_list
    end

    def getPubData(db_article, doi_text)
      if doi_text != ""
        data_mappings = getPubDataXRef(doi_text)
        just_article_vals = data_mappings[0]
        just_article_vals['status'] = "Incomplete"
        just_article_vals.compact!()
        db_article.update(just_article_vals)
        addPubAuthors(data_mappings[1], data_mappings[2], db_article)
      end
      db_article
    end

    def getPubDataXRef(doi_text)
      pub_data = XrefClient.getCRData(doi_text)
      XrefClient::ObjectMapper.map_xref_to_cdi(pub_data)
    end

    def addPubAuthors(pub_authors, pub_auth_affis, a_pub)
      pub_authors.each do |an_author|
        temp_id = an_author["author_order"]
        an_author["doi"] =  a_pub.doi
        an_author["article_id"] =  a_pub.id

        new_art_author = ArticleAuthor.new(an_author)
        found_id = get_researcher_match(new_art_author)
        if found_id != 0
          an_author["author_id"] = found_id
          an_author["status"] = "verified"
        else
          new_researcher = Author.new(given_name: new_art_author.given_name, last_name: new_art_author.last_name, orcid: new_art_author.orcid)
          if new_researcher.save
            an_author["author_id"] = new_researcher.id
          end
        end
        an_author.compact!()
        new_art_author.update!(an_author)

        pub_auth_affis.each do |affi_line|
          if affi_line["article_author_id"] == temp_id
            affi_line["article_author_id"] = new_art_author.id
            affi_line.compact!()
            new_cr_affi = CrAffiliation.new(affi_line)
            new_cr_affi.save
          end
        end
      end
    end

    def getAutData(db_authors, doi_text, art_id)
      pub_data = XrefClient.getCRData(doi_text)
      if pub_data
        aut_order = 1
        aut_count = pub_data['author'].count
        pub_data['author'].each do |art_author|
          new_author = ArticleAuthor.new()
          if art_id
            tem_auth = ArticleAuthor.find_by article_id: art_id, author_order: aut_order
            new_author = tem_auth if tem_auth
          end
          new_author.orcid       = art_author['ORCID']  if art_author.key?('ORCID')
          new_author.last_name   = art_author['family'] if art_author.key?('family')
          new_author.given_name  = art_author['given']  if art_author.key?('given')
          new_author.author_seq  = art_author['sequence'].to_s
          new_author.author_order= aut_order
          new_author.article_id  = art_id
          new_author.status      = "not verified"
          new_author.doi         = doi_text
          new_author.author_count= aut_count

          found_id = get_researcher_match(new_author)
          if found_id != 0
            new_author.author_id = found_id
            new_author.status = "verified"
          else
            new_researcher = Author.new(given_name: new_author.given_name, last_name: new_author.last_name, orcid: new_author.orcid)
            if new_researcher.save
              new_author.author_id = new_researcher.id
            end
          end

          if new_author.save
            if art_author.key?('affiliation') && art_author['affiliation'].count > 0
              art_author['affiliation'].each do |temp_affi|
                new_tmp_affi = CrAffiliation.new()
                new_tmp_affi.name = temp_affi['name']
                new_tmp_affi.article_author_id = new_author.id
                new_tmp_affi.save
              end
            end
            aut_order += 1
          end
        end
      end
    end

    def verify_articles(article)
      doi_text = article.doi
      return if doi_text.blank?
      pub_data = getCRData(doi_text)
      return if pub_data.nil?

      changes_found = false
      if article.attributes['referenced_by_count'] != pub_data['is-referenced-by-count']
        changes_found = true
        article.attributes['referenced_by_count'] = pub_data['is-referenced-by-count']
        article.referenced_by_count = pub_data['is-referenced-by-count']
      end
      article.save if changes_found
    end

    def get_researcher_match(new_author)
      # Before save get best author match
      plain_ln = "XXXXX%"
      if new_author.last_name.include?('-')
        plain_ln = new_author.last_name.gsub('-',' ')
      end
      # get a strig with only letters with no punctuations
      like_name = new_author.last_name.gsub(/[^a-zA-Z]/, '%')
      authors_list = Author.where(orcid: new_author.orcid, last_name: new_author.last_name)
        .or(Author.where(given_name: new_author.given_name, last_name: new_author.last_name))
        .or(Author.where(last_name: new_author.last_name))
        .or(Author.where(last_name: plain_ln))
        .or(Author.where("last_name ILIKE ?", "%" + like_name + "%"))

      found_id = 0
      authors_list.each do |researcher|
        if new_author.orcid && researcher.orcid && researcher.orcid == new_author.orcid
          found_id = researcher.id
          break
        elsif new_author.given_name == researcher.given_name && new_author.last_name == researcher.last_name
          found_id = researcher.id
          break
        end
      end
      found_id
    end

    def serialize_article(article, include_abstract: false)
      payload = {
        id:              article.id,
        doi:             article.doi,
        title:           article.title,
        pub_year:        article.pub_year,
        pub_type:        article.pub_type,
        container_title: article.container_title,
        publisher:       article.publisher,
        volume:          article.volume,
        issue:           article.issue,
        page:            article.page,
        url:             article.url,
        link:            article.link,
        graphic_abstract: article.graphic_abstract,
        themes:    article.themes.map { |t| { id: t.id, name: t.name, short: t.short, phase: t.phase } },
        theme_ids: article.themes.map(&:id)
      }

      if include_abstract
        raw = article.abstract.to_s
        # Optional: plain-text version (strips JATS/HTML if present)
        text = ActionView::Base.full_sanitizer.sanitize(raw).to_s.squish
        payload[:abstract] = raw
        payload[:abstract_text] = text
      end

      payload
    end

    def print_author(new_author)
      puts "######################AUTHOR###################################"
      puts "Name: " + new_author.last_name + " " + new_author.given_name
      puts "ORCID     " + new_author.orcid.to_s
      puts "Order:    " + new_author.author_order.to_s
      puts "Sequence: " + new_author.author_seq.to_s
      puts "Article ID: " + new_author.article_id.to_s
      puts "ID:       " + new_author.id.to_s
      puts "###############################################################"
    end
end
