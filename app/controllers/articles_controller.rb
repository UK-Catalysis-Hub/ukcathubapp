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

    orders 'Title (A-Z)' => :title,
           'Title desc. (Z-A)' => "title desc",
           'Year, newest first' => "pub_year desc",
           'Year, oldest first' => {pub_year: :asc, title: :asc}
  end
  

  # GET /articles or /articles.json
  def index
    @search = ArticleSearch.new(params) # this initializes your search object from the request params
    @articles = @search.result.active.paginate(:page => params[:page], :per_page => 10)
  end

  # GET /articles/1 or /articles/1.json
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
        puts "&"*80
        puts p_doi
        puts "&"*80
        p_themes = JSON.load(pub_row[10])

        @art = Article.find_by(doi: p_doi)
        if @art == nil
          @art = Article.new()
          @art.doi = p_doi
          getPubData(@art, @art.doi)
          puts @art.doi
          puts("\n*******************************************************")
          puts("NOT IN DB DOI: " + @art.doi.to_s +  @art.title.to_s + " themes " + p_themes.to_s() )
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
      puts "CALLED SET ARTICLE"
      # this is ok for an existing article
      @article = Article.find(params[:id])
      @authors = @article.article_authors
       
      # this should only happen when a doi is given
      # need to hanlde what happens if doi is invalid or blank 
      # enable manual input 
      if @article.title == nil
         # check if exists in DB by DOI
         @art = Article.find_by(doi: @article.doi)
         if @art.title == nil
           # this is a new article. Needs authors, and affiliation
           @article = getPubData(@article, @article.doi)
           #save the article so it is not recovered again
           @article.save()
         else
           @article= @art
         end
      end
      if @article.article_authors.count == 0 or @article.article_authors[0].last_name == nil
        puts "*"*90
        puts "Getting authors for: " + @article.doi
        puts "*"*90
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
       params.require(:article).permit(:doi, :title, :pub_year, :pub_type, :publisher, :container_title,
        :volume, :issue, :page, :pub_print_year, :pub_print_month, :pub_print_day, :pub_ol_year, :pub_ol_month,
        :pub_ol_day, :license, :referenced_by_count, :link, :url, :abstract, :status, :comment, :references_count,
        :journal_issue)
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
      puts "%"*90
      puts "Getting pub data"
      puts "%"*90
      if doi_text != ""
        # need to raise an exeption if doi is incorrect or no data is returned
        # need to check the doi is not in DB before saving (lower and uppercase versions)
        # need to trim dois before saving
        data_mappings = getPubDataXRef(doi_text) 
        # remove id, and timestamps from mappings before updating
        just_article_vals = data_mappings[0]
         # mark incomplete as it is missing authors, affiliation and themes
        just_article_vals['status'] = "Incomplete"
        just_article_vals.compact!() 
        db_article.update(just_article_vals)
        puts ("%"*80)
        puts("Added "+ db_article.doi)
        puts ("%"*80)
        # now add authors and affiliations
        addPubAuthors(data_mappings[1], data_mappings[2], db_article)
      end
      return db_article
    end
    
    def getPubDataXRef(doi_text)
      pub_data = XrefClient.getCRData(doi_text)
      data_mappings = XrefClient::ObjectMapper.map_xref_to_cdi(pub_data)
      return data_mappings   
    end
    
    def addPubAuthors(pub_authors,pub_auth_affis, a_pub)
      pub_authors.each do |an_author|
        temp_id = an_author["author_order"]
        an_author["doi"] =  a_pub.doi
        an_author["article_id"] =  a_pub.id
        
        new_art_author = ArticleAuthor.new(an_author)
        
        print_author(new_art_author)
        
        # check if the article author is in the researchers table
	found_id = get_researcher_match(new_art_author)
        if found_id != 0 then
          an_author["author_id"] = found_id
        else
          # create a new researcher (author)
          new_researcher = Author.new(given_name: new_art_author.given_name, last_name: new_art_author.last_name, orcid: new_art_author.orcid)
          if new_researcher.save then
            an_author["author_id"] = new_researcher.id
          end
        end
        
        an_author.compact!()
        
        new_art_author.update!(an_author)
 
        puts "8"*90
        puts "New article author saved with id: " + new_art_author.id.to_s
        puts "New article author assigned researcher id: " + new_art_author.author_id.to_s
        puts "New article author assigned article id: " + new_art_author.article_id.to_s
        puts "8"*90
        
        pub_auth_affis.each do |affi_line|
          if affi_line["article_author_id"] == temp_id
            affi_line["article_author_id"] = new_art_author.id
            affi_line.compact!()
            new_cr_affi = CrAffiliation.new(affi_line)
            new_cr_affi.save
            puts "8"*90
            puts "Address Line: " + affi_line["name"]
            puts "8"*90
          end
        end
      end
    end
 
    def getAutData(db_authors, doi_text, art_id)
      # shoudl correct having to get the data from crossref again when article is new
      pub_data = XrefClient.getCRData(doi_text)
      if pub_data != nil then
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
