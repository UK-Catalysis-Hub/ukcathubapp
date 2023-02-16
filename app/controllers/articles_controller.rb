class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show, :bib_query, :arts_by_year_stats]
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

  # Upload CSV articles list
  def upload_csv
    #VerifyCrossrefWorker.perform_async
    csv_file = params[:file]
    @pub_rows = CSV.read(csv_file.path)
    @pub_rows.each do |pub_row|
      if pub_row[4] != 'doi' and pub_row[10] != nil
        p_doi = pub_row[4]
        
        p_themes = JSON.load(pub_row[10])

        @art = Article.find_by(doi: p_doi)
        if @art == nil
          @art = Article.new()
          @art.doi = p_doi
          getPubData(@art, @art.doi)
          puts("\n*******************************************************")
          puts("NOT IN DB DOI: " + @art.doi +  @art.title + " themes " + p_themes.to_s() )
          puts("*******************************************************\n")
          if @art.container_title == nil
            @art.container_title = pub_row[15]
          end
          @art.save()
          
          puts("\n*******************************************************")
          puts("ADDED AS ID " + @art.id.to_s())
          puts("*******************************************************\n")
          # add theme links
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
          puts("IN DB DOI: " +  p_doi + " themes " + p_themes.to_s())
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
    articles = Article.active.all()
    if (params.has_key?('year') and  params.has_key?('theme'))
      articles = Article.active.where(pub_year: params[:year]).joins(:themes).where(:themes=> {short: params[:theme]})
    elsif ( params.has_key?('year') )
      articles = Article.active.where(pub_year: params[:year])
    elsif ( params.has_key?('theme') )
      articles = Article.active.joins(:themes).where(:themes=> {short: params[:theme]})
    else
      puts '----- NO PARAMETERS -------' 
    end
    bib_data = get_bib_data(articles)
    #puts articles.count
    respond_to do |format|
      msg = { :status => "ok", :message => "Success!", :html => "<b>...</b>" }
      format.json  { render :json => bib_data } # don't do msg.to_json
    end
  end
  
  # download publication stats
  def arts_by_year_stats
    arts_by_year = Article.where(:status => "Added").group(:pub_year).count.collect{|pb| [pb[0], pb[1]]}
    arts_by_year_csv = get_csv(['year','count'], arts_by_year)   
    send_data(arts_by_year_csv, 
              :type => 'text/plain', :disposition => 'attachment', :filename => 'ukch_pub_stats.csv')
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

           @article = getPubData(@article, @article.doi)
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
    def get_excluded()
      return ['author','assertion','indexed', 'funder','content-domain',
        'created','update-policy','source','is-referenced-by-count','prefix',
        'member','reference','original-title','language','deposited','score',
        'subtitle', 'short-title', 'issued','alternative-id','relation','ISSN',
        'container-title-short']
    end

    # get list of publications as bibliography
    def get_bib_data(articles)
      bib_list=[]
      articles.each do |article|
        author_list = article.authors.all
        disp_names = ""
        author_list.each do|auth|
           pr_name = auth.given_name.gsub('á','a').gsub('é','e').gsub('í','i').gsub('ó','o').gsub('ú','u')
           pr_name = pr_name.gsub(/\w+/){|s| "#{s[0].upcase}. "}.sub(/\w+\z/, &:capitalize).sub(' .',' ')
           pr_name += auth.last_name
           this_name = pr_name
           if disp_names == ""
             disp_names =  + this_name
           else
             disp_names += ', ' + this_name
           end
        end
        bib_list.append({"title"=>article.title, "year"=>article.pub_year, "authors"=>disp_names,
                         "publisher" => article.container_title, "doi"=>article.doi, 
                         "pub_type"=> article.pub_type,'volume'=>article.volume, 
                         'issue'=>article.issue,'page'=> article.page})
      end
      return bib_list
    end

    def getPubData(db_article, doi_text)
      if doi_text != ""
        # need to raise an exeption if doi is incorrect or no data is returned
        # need to check the doi is not in DB before saving (lower and uppercase versions)
        # need to trim dois before saving
        pub_data = XrefClient.getCRData(doi_text)
        data_mappings = XrefClient::ObjectMapper.map_xref_to_cdi(pub_data) 
        puts "###################################################################"
        puts data_mappings
        db_article = Article.new(data_mappings[0])
        puts db_article.title
        puts "*******************************************************************"
      end
      # mark incomplete as it is missing authors, affiliation and themes
      db_article.status = "Incomplete"
      return db_article
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
