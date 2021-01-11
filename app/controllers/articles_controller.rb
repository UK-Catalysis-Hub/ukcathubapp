class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  class ArticleSearch < FortyFacets::FacetSearch
    model 'Article' # which model to search for
    scope :active  # only return articles which are in the scope 'active'
    text :title   # filter by a generic string entered by the user
    facet :pub_year, name: 'Year', order: Proc.new { |pub_year| -pub_year }# additionally order values in the year field
    facet :container_title, name: 'Journal', order: Proc.new { |container_title| container_title }
    facet :publisher, name: 'Publisher', order: Proc.new { |publisher| publisher }

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
    session[:return_to] = request.referer
  end

  # POST /articles
  # POST /articles.json
  def create
    puts article_params
    @article = Article.new(article_params)
    respond_to do |format|
      if @article.save
        if @article.doi != ""
          format.html { redirect_to @article, notice: 'Article was created.' }
          format.json { render :show, status: :created, location: @article }
        else
          format.html { redirect_to edit_article_path(@article), notice: 'Input article details' }
        end
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
        format.html { redirect_to @article, notice: 'Article was updated.' }
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
    VerifyCrossrefWorker.perform_async
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

      if @article.title == nil
         # check if exists in DB by DOI
         @art = Article.find_by(doi: @article.doi)
         if @art.title == nil

           getPubData(@article, @article.doi)
           #save the article so it is not recovered again
           @article.save()
         else
           @article= @art
         end
      end

      if @article.article_authors.count == 0 or @article.article_authors[0].last_name == nil
        # try to get authors from crossref
        getAutData(@authors, @article.doi, @article.id)
      end

      if @article.pub_year == nil then
        @article.pub_ol_year != nil ? @article.pub_year = @article.pub_ol_year : @article.pub_year = @article.pub_print_year
        #save the article if it did not have pub_year set
        @article.save()
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
      if doi_text != ""
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
        if pub_data.keys.include?('journal_issue') \
          and pub_data['journal_issue'] != nil then
          if pub_data['journal_issue'].keys.include?('issue') then
            db_article.journal_issue = pub_data['journal_issue']['issue']
          end
          if pub_data['journal_issue']['published-print']['date-parts'][0].length == 1 then
            #assume that if date parts has only one element, it is year
            db_article.pub_ol_year = pub_data['journal_issue']['published-print']['date-parts'][0][0]
          elsif pub_data['journal_issue']['published-print']['date-parts'][0].length == 2 then
            #assume that if date parts has two elements, they are year and month
            db_article.pub_ol_year = pub_data['journal_issue']['published-print']['date-parts'][0][0]
            db_article.pub_ol_month = pub_data['journal_issue']['published-print']['date-parts'][0][1]
          elsif pub_data['journal_issue']['published-print']['date-parts'][0].length == 3 then
            # assume year, month and day if date parts has three elements
            db_article.pub_print_year = pub_data['journal_issue']['published-print']['date-parts'][0][0]
            db_article.pub_print_month = pub_data['journal_issue']['published-print']['date-parts'][0][1]
            db_article.pub_print_day = pub_data['journal_issue']['published-print']['date-parts'][0][2]
          end
        end
        db_article.container_title = pub_data['container_title']
        db_article.page = pub_data['page']
        db_article.abstract = pub_data['abstract']
        print pub_data.keys
        if pub_data.keys.include?('published_online') then
          if pub_data['published_online']['date-parts'][0].length == 1 then
            #assume that if date parts has only one element, it is year
            db_article.pub_ol_year = pub_data['published_online']['date-parts'][0][0]
          elsif pub_data['published_online']['date-parts'].length == 2 then
            #assume that if date parts has two elements, they are year and month
            db_article.pub_ol_year = pub_data['published_online']['date-parts'][0][0]
            db_article.pub_ol_month = pub_data['published_online']['date-parts'][0][1]
          elsif pub_data['published_online']['date-parts'][0].length == 3 then
            # assume year, month and day if date parts has three elements
            db_article.pub_ol_year = pub_data['published_online']['date-parts'][0][0]
            db_article.pub_ol_month = pub_data['published_online']['date-parts'][0][1]
            db_article.pub_ol_day = pub_data['published_online']['date-parts'][0][2]
          end
        end
        if pub_data.keys.include?('published_print') then
          if pub_data['published_print']['date-parts'][0].length == 1 then
            #assume that if date parts has only one element, it is year
            db_article.pub_ol_year = pub_data['published_print']['date-parts'][0][0]
          elsif pub_data['published_print']['date-parts'][0].length == 2 then
            #assume that if date parts has two elements, they are year and month
            db_article.pub_ol_year = pub_data['published_print']['date-parts'][0][0]
            db_article.pub_ol_month = pub_data['published_print']['date-parts'][0][1]
          elsif pub_data['published_print']['date-parts'][0].length == 3 then
            # assume year, month and day if date parts has three elements
            db_article.pub_print_year = pub_data['published_print']['date-parts'][0][0]
            db_article.pub_print_month = pub_data['published_print']['date-parts'][0][1]
            db_article.pub_print_day = pub_data['published_print']['date-parts'][0][2]
          end
        end
      end
      # mark incomplete as it is missing authors, affiliation and themes
      db_article.status = "Incomplete"
    end

    def getAutData(db_authors, doi_text, art_id)
      pub_data = CrossrefApiClient.getCRData(doi_text)
      if pub_data != nil then
        puts "\nPub data: " + pub_data.class.to_s
        aut_order = 1
        aut_count = pub_data['author'].count
        pub_data['author'].each do |art_author|
          new_author = ArticleAuthor.new()
          if art_id != nil
            tem_auth = ArticleAuthor.find_by article_id: art_id, author_order: aut_order
            if tem_auth != nil then
              new_author = tem_auth
            end
          end
          if art_author.keys.include?('ORCID')
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
          new_author.article_id = art_id
          new_author.status = "not verified"
          new_author.doi = doi_text
          new_author.author_count = aut_count
          # Before save get best author match
          found_id = get_researcher_match(new_author)

          if found_id != 0 then
            new_author.author_id = found_id
          else
            # create a new researcher (author)
            new_researcher = Author.new(given_name: new_author.given_name,
              last_name: new_author.last_name, orcid: new_author.orcid)
            if new_researcher.save then
              new_author.author_id = new_researcher.id
            end
          end

          if new_author.save then
            print_author(new_author)
            if art_author.keys.include?('affiliation')
              # get new affiliations and save them
              puts "**********************************************************"
              puts art_author['affiliation'].to_s
              puts "**********************************************************"
              if art_author['affiliation'].count > 0 then
                art_author['affiliation'].each { |temp_affi|
                  new_tmp_affi = CrAffiliation.new()
                  new_tmp_affi.name = temp_affi['name']
                  new_tmp_affi.article_author_id = new_author.id
                  new_tmp_affi.save
                }
              end
            end
            aut_order += 1
          end
        end
      end
    end

    def verify_articles(article)
      # Check for changes in number of refferences to publication
      # get the article from crossref
      doi_text = article.doi
      art_id = article.id
      if article.doi != ""
        pub_data = getCRData(doi_text)
        changes_found = false
        # only verify fields which may change between recoveries, eg: citations
        if article.attributes['referenced_by_count'] != pub_data['is-referenced-by-count']
          changes_found = true
          article.attributes['referenced_by_count'] = pub_data['is-referenced-by-count']
          article.referenced_by_count = pub_data['is-referenced-by-count']
        end
        if changes_found
          article.save
        end
      end
    end

    def get_researcher_match(new_author)
      # Before save get best author match
      plain_ln = "XXXXX%"
      if new_author.last_name.include?('-')
        plain_ln = new_author.last_name.gsub('-',' ')
      end
      # get a strig with only letters with no punctuations
      like_name = "XXXX%"
      if (new_author.last_name =~ /[^a-zA-Z\s:]/) != nil
        non_alpha_found = true
        like_name = new_author.last_name.gsub(" ","%")
        while non_alpha_found
          c_idx = (like_name =~ /[^a-zA-Z\s:]/)
          if c_idx != nil
            like_name[c_idx] = " "
          else
            non_alpha_found = false
          end
        end
        like_name.gsub!(' ','%')
      end

      authors_list = Author.where(orcid: new_author.orcid, last_name: new_author.last_name)
        .or(Author.where(given_name: new_author.given_name, last_name: new_author.last_name))
        .or(Author.where(last_name: new_author.last_name))
        .or(Author.where(last_name: plain_ln))
        .or(Author.where("last_name LIKE ?", "%" + like_name + "%"))

      found_id = 0
      authors_list.each { |researcher|
        if new_author.orcid !=nil and  researcher.orcid != nil \
           and researcher.orcid == new_author.orcid
           found_id = researcher.id
           break
        elsif new_author.given_name == researcher.given_name and \
          new_author.last_name == researcher.last_name
          found_id = researcher.id
          break
        end
      }
      return found_id
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
