class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy]

  class DatasetSearch < FortyFacets::FacetSearch
    model 'Dataset' # which model to search for
    text :dataset_name, name: 'Data object name'  # filter by a generic string entered by the user
    facet :ds_type, name: 'Data object type'
    facet :repository, name: 'Repository'

    orders 'Name' => :dataset_name,
           'Name, descending' => "dataset_name desc"
  end

  # GET /datasets
  # GET /datasets.json
  def index
    @search = DatasetSearch.new(params)
    @datasets = @search.result.paginate(:page => params[:page], :per_page => 10)
  end

  # GET /datasets/1
  # GET /datasets/1.json
  def show
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/1/edit
  def edit
  end

  # POST /datasets
  # POST /datasets.json
  def create
    @dataset = Dataset.new(dataset_params)

    respond_to do |format|
      if @dataset.save
        format.html { redirect_to @dataset, notice: 'Dataset was successfully created.' }
        format.json { render :show, status: :created, location: @dataset }
      else
        format.html { render :new }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /datasets/1
  # PATCH/PUT /datasets/1.json
  def update
    respond_to do |format|
      if @dataset.update(dataset_params)
        format.html { redirect_to @dataset, notice: 'Dataset was successfully updated.' }
        format.json { render :show, status: :ok, location: @dataset }
      else
        format.html { render :edit }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /datasets/1
  # DELETE /datasets/1.json
  def destroy
    @dataset.destroy
    respond_to do |format|
      format.html { redirect_to datasets_url, notice: 'Dataset was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dataset
      @dataset = Dataset.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dataset_params
      params.require(:dataset).permit(:dataset_complete, :dataset_description, :dataset_doi, :dataset_enddate, :dataset_location, :dataset_name, :dataset_startdate, :ds_type, :repository)
    end
end
