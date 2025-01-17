class ArticleThemesController < ApplicationController
  before_action :set_article_theme, only: %i[ show edit update destroy ]

  # GET /article_themes or /article_themes.json
  def index
    @article_themes = ArticleTheme.all
  end

  # GET /article_themes/1 or /article_themes/1.json
  def show
  end

  # GET /article_themes/new
  def new
    @article_theme = ArticleTheme.new
  end

  # GET /article_themes/1/edit
  def edit
  end

  # POST /article_themes or /article_themes.json
  def create
    @article_theme = ArticleTheme.new(article_theme_params)

    respond_to do |format|
      if @article_theme.save
        format.html { redirect_to article_theme_url(@article_theme), notice: "Article theme was successfully created." }
        format.json { render :show, status: :created, location: @article_theme }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article_theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /article_themes/1 or /article_themes/1.json
  def update
    respond_to do |format|
      if @article_theme.update(article_theme_params)
        format.html { redirect_to article_theme_url(@article_theme), notice: "Article theme was successfully updated." }
        format.json { render :show, status: :ok, location: @article_theme }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article_theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /article_themes/1 or /article_themes/1.json
  def destroy
    @article_theme.destroy!

    respond_to do |format|
      format.html { redirect_to article_themes_url, notice: "Article theme was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article_theme
      @article_theme = ArticleTheme.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_theme_params
      params.require(:article_theme).permit(:doi, :phase, :collaboration, :theme_id, :article_id, :project_year)
    end
end