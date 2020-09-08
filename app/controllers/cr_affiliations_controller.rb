class CrAffiliationsController < ApplicationController
  before_action :set_cr_affiliation, only: [:show, :edit, :update, :destroy]

  # GET /cr_affiliations
  # GET /cr_affiliations.json
  def index
    @cr_affiliations = CrAffiliation.all
  end

  # GET /cr_affiliations/1
  # GET /cr_affiliations/1.json
  def show
  end

  # GET /cr_affiliations/new
  def new
    @cr_affiliation = CrAffiliation.new
  end

  # GET /cr_affiliations/1/edit
  def edit
  end

  # POST /cr_affiliations
  # POST /cr_affiliations.json
  def create
    @cr_affiliation = CrAffiliation.new(cr_affiliation_params)

    respond_to do |format|
      if @cr_affiliation.save
        format.html { redirect_to @cr_affiliation, notice: 'Cr affiliation was successfully created.' }
        format.json { render :show, status: :created, location: @cr_affiliation }
      else
        format.html { render :new }
        format.json { render json: @cr_affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cr_affiliations/1
  # PATCH/PUT /cr_affiliations/1.json
  def update
    respond_to do |format|
      if @cr_affiliation.update(cr_affiliation_params)
        format.html { redirect_to @cr_affiliation, notice: 'Cr affiliation was successfully updated.' }
        format.json { render :show, status: :ok, location: @cr_affiliation }
      else
        format.html { render :edit }
        format.json { render json: @cr_affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cr_affiliations/1
  # DELETE /cr_affiliations/1.json
  def destroy
    @cr_affiliation.destroy
    respond_to do |format|
      format.html { redirect_to cr_affiliations_url, notice: 'Cr affiliation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cr_affiliation
      @cr_affiliation = CrAffiliation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cr_affiliation_params
      params.require(:cr_affiliation).permit(:name, :article_author_id, :affiliation_id)
    end
end
