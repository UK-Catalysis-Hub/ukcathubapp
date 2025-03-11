class ArticleAuthorsController < ApplicationController
  before_action :set_article_author, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /article_authors or /article_authors.json
  def index
    @article_authors = ArticleAuthor.all
  end

  # GET /article_authors/1 or /article_authors/1.json
  def show
  end

  # GET /article_authors/new
  def new
    @article_author = ArticleAuthor.new
  end

  # GET /article_authors/1/edit
  def edit
  end

  # POST /article_authors or /article_authors.json
  def create
    @article_author = ArticleAuthor.new(article_author_params)

    respond_to do |format|
      if @article_author.save
        format.html { redirect_to article_author_url(@article_author), notice: "Article author was successfully created." }
        format.json { render :show, status: :created, location: @article_author }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article_author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /article_authors/1 or /article_authors/1.json
  def update
    respond_to do |format|
      if @article_author.update(article_author_params)
        format.html { redirect_to article_author_url(@article_author), notice: "Article author was successfully updated." }
        format.json { render :show, status: :ok, location: @article_author }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article_author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /article_authors/1 or /article_authors/1.json
  def destroy
    @article_author.destroy!

    respond_to do |format|
      format.html { redirect_to article_authors_url, notice: "Article author was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Assign researcher(author) to article author record
  def link_to_researcher
    # get the researcher id from the parameters
    # get the article id from the parameters
    # save article_author
    # redirect to article edit
    @article_author = ArticleAuthor.find(params["data"]["id"])
    update_hash = {:author_id=>params["data"]["author_id"], :status => 'verified'}
    @article_author.update(update_hash)
    respond_to do |format|
      flash[:notice] = 'researcher verified'
      format.html { redirect_to return_url }
    end
  end

  private
    def return_url
      url_for(controller: 'articles', action: 'edit', id: params["data"]["article_id"]) || article_authors_url
    
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_article_author
      @article_author = ArticleAuthor.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_author_params
      params.require(:article_author).permit(:doi, :author_id, :author_count, :author_order, :status, :author_seq, :article_id, :orcid, :last_name, :given_name)
    end
end
