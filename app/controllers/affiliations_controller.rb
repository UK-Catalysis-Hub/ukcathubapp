class AffiliationsController < ApplicationController
  before_action :set_affiliation, only: %i[ show edit update destroy ]

  # GET /affiliations or /affiliations.json
  def index
    @affiliations = Affiliation.all
  end

  # GET /affiliations/1 or /affiliations/1.json
  def show
  end

  # GET /affiliations/new
  def new
    @affiliation = Affiliation.new
  end

  # GET /affiliations/1/edit
  def edit
  end

  # POST /affiliations or /affiliations.json
  def create
    @affiliation = Affiliation.new(affiliation_params)

    respond_to do |format|
      if @affiliation.save
        format.html { redirect_to affiliation_url(@affiliation), notice: "Affiliation was successfully created." }
        format.json { render :show, status: :created, location: @affiliation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /affiliations/1 or /affiliations/1.json
  def update
    respond_to do |format|
      if @affiliation.update(affiliation_params)
        format.html { redirect_to affiliation_url(@affiliation), notice: "Affiliation was successfully updated." }
        format.json { render :show, status: :ok, location: @affiliation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /affiliations/1 or /affiliations/1.json
  def destroy
    @affiliation.destroy!

    respond_to do |format|
      format.html { redirect_to affiliations_url, notice: "Affiliation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_affiliation
      @affiliation = Affiliation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def affiliation_params
      params.require(:affiliation).permit(:institution, :department, :faculty, :school, :work_group, :country, :sector)
    end
end
