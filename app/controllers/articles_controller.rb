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
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:doi, :title, :pub_year, :pub_type, :publisher, :container_title, :volume, :issue, :page, :pub_print_year, :pub_print_month, :pub_print_day, :pub_ol_year, :pub_ol_month, :pub_ol_day, :license, :referenced_by_count, :link, :url, :abstract, :status, :comment, :references_count, :journal_issue)
    end
end
