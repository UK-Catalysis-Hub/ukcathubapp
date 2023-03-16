class ArticleAuthorsController < ApplicationController
  before_action :set_article_author, only: [:show, :edit, :update, :destroy]

  #before_action :skip_forgery_protection, only: [:link_to_researcher]
  # GET /article_authors
  # GET /article_authors.json
  def index
    @article_authors = ArticleAuthor.all
  end

  # GET /article_authors/1
  # GET /article_authors/1.json
  def show
  end

  # GET /article_authors/new
  def new
    @article_author = ArticleAuthor.new
  end

  # GET /article_authors/1/edit
  def edit
  end

  # POST /article_authors
  # POST /article_authors.json
  def create
    @article_author = ArticleAuthor.new(article_author_params)

    respond_to do |format|
      if @article_author.save
        format.html { redirect_to @article_author, notice: 'Article author was successfully created.' }
        format.json { render :show, status: :created, location: @article_author }
      else
        format.html { render :new }
        format.json { render json: @article_author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /article_authors/1
  # PATCH/PUT /article_authors/1.json
  def update
    if params.has_key?("commit") and params["commit"] == "Assign"
      puts params["article_author"]["author_id"]
      params["article_author"]["status"] = "not verified"
    end
    respond_to do |format|
      if @article_author.update(article_author_params)
        format.html { redirect_to @article_author, notice: 'Article author was successfully updated.' }
        format.json { render :show, status: :ok, location: @article_author }
      else
        format.html { render :edit }
        format.json { render json: @article_author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /article_authors/1
  # DELETE /article_authors/1.json
  def destroy
    @article_author.destroy
    respond_to do |format|
      format.html { redirect_to article_authors_url, notice: 'Article author was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Assign researcher(author) to article author record
  def link_to_researcher
    # get the researcher id from the parameters
    # get the article id from the parameters
    # save article_author
    # redirect to article edit
    puts "********************************************************************"
    puts params
    puts params["data"]
    @article_author = ArticleAuthor.find(params["data"]["id"])
    update_hash = {:author_id=>params["data"]["author_id"], :status => 'verified'}
    @article_author.update(update_hash)
    puts "********************************************************************"
    respond_to do |format|
      flash[:notice] = 'researcher verified'
      return_to = session[:return_to]
      return_to.include?("/edit") ? true : return_to = return_to + "/edit"
      format.html { redirect_to return_to }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article_author
      @article_author = ArticleAuthor.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_author_params
      params.require(:article_author).permit(:doi, :author_id, :author_count, :author_order, :status, :author_seq, :article_id, :orcid, :last_name, :given_name)
    end
end
