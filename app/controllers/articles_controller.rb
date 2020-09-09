class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  class ArticleSearch < FortyFacets::FacetSearch
    model 'Article' # which model to search for
    text :title   # filter by a generic string entered by the user
    scope :active   # only return articles which are in the scope 'active'
    facet :pub_year, name: 'Pub Year', order: :pub_year # additionally order values in the year field
    facet :container_title, name: 'Publisher'#, order: :container_title

    orders 'Title' => :title,
           'Year, newest first' => "pub_year desc",
           'Year, oldest first' => {pub_year: :asc, title: :asc}
  end

  # GET /articles
  # GET /articles.json
  def index
    @search = ArticleSearch.new(params) # this initializes your search object from the request params
    @articles = @search.result.active.paginate(:page => params[:page], :per_page => 10)
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
    puts article_params
    @article = Article.new(article_params)
    respond_to do |format|
      puts @article.doi
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # VERIFY records in CR
  def verify
    puts 'verify all publications against CR records'
    date_from = Date.today - 30
    articles_list = Article.where("updated_at < ?", date_from)
    #break counter
    bk_i = 1
    articles_list.each do |an_article|
      doi_text = an_article.doi
      verify_article(an_article)
      if bk_i == 10
        break
      end
      bk_i += 1
    end
    respond_to do |format|
      flash[:notice] = 'verify process started'
      format.html { redirect_to action: "index" }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
      @authors = @article.article_authors

      #puts "--------------------------------------------------"
      #puts @article.title
      #puts "--------------------------------------------------"
      if @article.title == nil
         getPubData(@article, @article.doi)
      end
      if @article.article_authors.count == 0 or @article.article_authors[0].last_name == nil
        puts "--------------------------------------------------"
        puts "Need to add authors"
        puts "--------------------------------------------------"
        # get authors from crossref
        getAutData(@authors, @article.doi, @article.id)
      end
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:referenced_by_count, :publisher, :issue, :license, :pub_print_year, :pub_print_month, :pub_print_day, :doi, :pub_type, :page, :title, :volume, :pub_ol_year, :pub_ol_month, :pub_ol_day, :container_title, :link, :references_count, :journal_issue, :url, :abstract, :status, :comment, :pub_year)
    end

    # functions for getting data from crossref
    include Serrano
    def get_excluded()
      return ['author','assertion','indexed', 'funder','content-domain',
        'created','update-policy','source','is-referenced-by-count','prefix',
        'member','reference','original-title','language','deposited','score',
        'subtitle', 'short-title', 'issued','alternative-id','relation','ISSN',
        'container-title-short']
    end

    def getCRData(doi_text)
      begin
          #puts "trying"
          art_bib = JSON.parse(Serrano.content_negotiation(ids: doi_text, format: "citeproc-json"))
          return art_bib
      rescue
          #puts "failing"
          return nil
      end
    end

    def getPubData(db_article, doi_text)
      pub_data = getCRData(doi_text)
      data_keys = pub_data.keys()
      pub_columns = []
      exclude_columns = get_excluded()
      for key in data_keys do
        key_cp = key.dup()
        if not pub_columns.include?(key_cp) and not exclude_columns.include?(key_cp)
          pub_columns.append(key_cp)
        end
      end
      for key in pub_columns
        key_cp = key.dup()
        if key_cp.include?('-')
          new_key = key_cp.gsub('-','_')
          pub_columns.delete(key_cp)
          pub_columns.append(new_key)
          pub_data[new_key] = pub_data[key]
          pub_data.delete(key_cp)
        end
      end
      for frzkey in ['container-title', 'journal-issue']
        pub_columns.delete(frzkey)
        new_key = frzkey.gsub('-','_')
        pub_columns.append(new_key)
        pub_data[new_key] = pub_data[frzkey]
        pub_data.delete(frzkey)
      end
      puts "###################################################################"
      puts pub_columns
      puts pub_data
      puts "###################################################################"
      puts pub_data['title']
      db_article.title = pub_data['title']
      db_article.publisher = pub_data['publisher']
      db_article.issue = pub_data['issue']
      db_article.pub_type = pub_data['type']
      db_article.license = pub_data['license']
      db_article.volume = pub_data['volume']
      db_article.referenced_by_count = pub_data['is_referenced_by_count']
      db_article.references_count = pub_data['references_count']
      db_article.link = pub_data['link']
      db_article.url = pub_data['URL']
      db_article.journal_issue = pub_data['journal_issue']['issue']
      db_article.container_title = pub_data['container_title']
      db_article.page = pub_data['page']
      db_article.abstract = pub_data['abstract']
      if pub_data['published_online']['date-parts'][0].length == 1
        #assume that if date parts has only one element, it is year
        db_article.pub_ol_year = pub_data['published_online']['date-parts'][0][0]
      elsif pub_data['published_online']['date-parts'].length == 2
        #assume that if date parts has two elements, they are year and month
        db_article.pub_ol_year = pub_data['published_online']['date-parts'][0][0]
        db_article.pub_ol_month = pub_data['published_online']['date-parts'][0][1]
      elsif pub_data['published_online']['date-parts'][0].length == 3
        # assume year, month and day if date parts has three elements
        db_article.pub_ol_year = pub_data['published_online']['date-parts'][0][0]
        db_article.pub_ol_month = pub_data['published_online']['date-parts'][0][1]
        db_article.pub_ol_day = pub_data['published_online']['date-parts'][0][2]
      end
      puts(pub_data['journal_issue'])
      puts(pub_data['journal_issue']['published-print']['date-parts'][0].length)
      if pub_data['journal_issue']['published-print']['date-parts'][0].length == 1
        #assume that if date parts has only one element, it is year
        db_article.pub_ol_year = pub_data['journal_issue']['published-print']['date-parts'][0][0]
      elsif pub_data['journal_issue']['published-print']['date-parts'][0].length == 2
        #assume that if date parts has two elements, they are year and month
        db_article.pub_ol_year = pub_data['journal_issue']['published-print']['date-parts'][0][0]
        db_article.pub_ol_month = pub_data['journal_issue']['published-print']['date-parts'][0][1]
      elsif pub_data['journal_issue']['published-print']['date-parts'][0].length == 3
        # assume year, month and day if date parts has three elements
        db_article.pub_print_year = pub_data['journal_issue']['published-print']['date-parts'][0][0]
        db_article.pub_print_month = pub_data['journal_issue']['published-print']['date-parts'][0][1]
        db_article.pub_print_day = pub_data['journal_issue']['published-print']['date-parts'][0][2]
      end
      # mark incomplete as it is missing authors, affiliation and themes
      db_article.status = "Incomplete"
    end

    def getAutData(db_authors, doi_text, art_id)
      pub_data = getCRData(doi_text)
      aut_order = 1
      pub_data['author'].each do |art_author|
        new_author = ArticleAuthor.new()
        if art_id != nil
          tem_auth = ArticleAuthor.find_by article_id: art_id, author_order: aut_order
          if tem_auth != nil
            new_author = tem_auth
          end
        end
        if art_author.keys.include?('ORCID')
          puts new_author.orcid.to_s
          new_author.orcid = art_author['ORCID']
        end
        if art_author.keys.include?('family')
          new_author.last_name = art_author['family']
        end
        if art_author.keys.include?('given')
          new_author.given_name = art_author['given']
        end
        new_author.author_seq = art_author['sequence'].to_s
        new_author.author_order = aut_order

        new_author.save

        puts "###################################################################"
        puts "Author ID:" + new_author.id.to_s
        if art_author.keys.include?('affiliation')
          puts art_author['affiliation']
          if art_author['affiliation'].length > 0
            art_author['affiliation'].each do |temp_affi|
              new_tmp_affi = CrAffiliation.new()
              new_tmp_affi.name = temp_affi['name']
              new_tmp_affi.article_author_id = new_author.id
              new_tmp_affi.save
            end
          end
        end
        puts db_authors[0].last_name
        puts "###################################################################"
        aut_order += 1

      end
    end

    def verify_article(article)
      # get the article from crossref
      doi_text = article.doi
      art_id = article.id
      pub_data = getCRData(doi_text)
      changes_found = false
      # only verify fields which may chenge between recoveries, eg: citations
      if article.attributes['referenced_by_count'] != pub_data['is-referenced-by-count']
        changes_found = true
        article.attributes['referenced_by_count'] = pub_data['is-referenced-by-count']
        article.referenced_by_count = pub_data['is-referenced-by-count']
      end
      if changes_found
        article.save
      end
      aut_order = 1
      pub_data['author'].each do |art_author|
        changes_found = false
        new_author = ArticleAuthor.new()
        if art_id != nil
          tem_auth = ArticleAuthor.find_by article_id: art_id, author_order: aut_order
          if tem_auth != nil
            new_author = tem_auth
          end
        end
        if art_author.keys.include?('ORCID')
          if  new_author.orcid != art_author['ORCID']
            changes_found = true
            new_author.orcid = art_author['ORCID']
          end
        end
        if art_author.keys.include?('family')
          if new_author.last_name != art_author['family']
            changes_found = true
            new_author.last_name = art_author['family']
          end
        end
        if art_author.keys.include?('given')
          if new_author.given_name != art_author['given']
            changes_found = true
            new_author.given_name = art_author['given']
          end
        end
        if changes_found
          new_author.save
        end
        aut_id = new_author.id
        if art_author.keys.include?('affiliation')
          if art_author['affiliation'].length > 0
            art_author['affiliation'].each do |temp_affi|
              new_affi = CrAffiliation.new()
              affi_text = temp_affi['name']
              if aut_id != nil
                tem_affi = CrAffiliation.find_by article_author_id: aut_id, name: affi_text
                if tem_affi != nil
                  new_affi = tem_affi
                else
                  new_affi.name = temp_affi['name']
                  new_affi.article_author_id = aut_id
                  new_affi.save
                end
              end
            end
          end
        end
        aut_order += 1
      end
    end
end
