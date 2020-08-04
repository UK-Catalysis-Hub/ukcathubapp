class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  class ArticleSearch < FortyFacets::FacetSearch
    model 'Article' # which model to search for
    text :title   # filter by a generic string entered by the user
    scope :active   # only return articles which are in the scope 'active'
    #range :pub_year, name: 'YearPublished' # filter by ranges for decimal fields
    facet :pub_year, name: 'YearPublished', order: :pub_year # additionally order values in the year field
    facet :container_title, name: 'Publisher'#, order: :container_title
    #facet :genres, name: 'Genre' # generate a filter with all values of 'genre' occuring in the result
    facet [:themes, :name], name: 'Theme' # generate a filter several belongs_to 'hops' away

    orders 'Title' => :title,
           'pub_year, newest first' => "pub_year desc",
           'pub_year, oldest first' => {pub_year: :asc, title: :asc}
    #custom :for_manual_handling
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
    @article = Article.new(article_params)

    respond_to do |format|
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:reference_count, :publisher, :issue, :license, :pub_print_year, :pub_print_month, :pub_print_day, :doi, :pub_type, :page, :title, :volume, :pub_ol_year, :pub_ol_month, :pub_ol_day, :container_title, :link, :references_count, :journal_issue, :url, :abstract, :status, :comment)
    end
end
