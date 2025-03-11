class ArticleDatasetsController < ApplicationController
  before_action :set_article_dataset, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  # GET /article_datasets or /article_datasets.json
  def index
    @article_datasets = ArticleDataset.all
  end

  # GET /article_datasets/1 or /article_datasets/1.json
  def show
  end

  # GET /article_datasets/new
  def new
    @article_dataset = ArticleDataset.new
  end

  # GET /article_datasets/1/edit
  def edit
  end

  # POST /article_datasets or /article_datasets.json
  def create
    @article_dataset = ArticleDataset.new(article_dataset_params)

    respond_to do |format|
      if @article_dataset.save
        format.html { redirect_to article_dataset_url(@article_dataset), notice: "Article dataset was successfully created." }
        format.json { render :show, status: :created, location: @article_dataset }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article_dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /article_datasets/1 or /article_datasets/1.json
  def update
    respond_to do |format|
      if @article_dataset.update(article_dataset_params)
        format.html { redirect_to article_dataset_url(@article_dataset), notice: "Article dataset was successfully updated." }
        format.json { render :show, status: :ok, location: @article_dataset }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article_dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /article_datasets/1 or /article_datasets/1.json
  def destroy
    @article_dataset.destroy!

    respond_to do |format|
      format.html { redirect_to article_datasets_url, notice: "Article dataset was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article_dataset
      @article_dataset = ArticleDataset.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_dataset_params
      params.require(:article_dataset).permit(:doi, :article_id, :dataset_id)
    end
end
