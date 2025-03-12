class AffiliationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :ctry_affi_count]
  before_action :set_affiliation, only: [:show, :edit, :update, :destroy]
  class AffiliationSearch < FortyFacets::FacetSearch
    model 'Affiliation' # which model to search for
    # issue a filter cannot be also a facet, need 'alias'?
    #text  :institution # filter by a generic string entered by the user
    facet  :institution, name: 'Institution'
    facet :country, name: 'Country'
    facet :department, name: 'Department'
    facet :school, name: 'School'
    facet :sector, name: 'Sector'
    
    orders 'Institution (A-Z)' => {institution: :asc, department: :asc},
           'Institution (Z-A)' => {institution: :desc, department: :desc},
           'Country (A-Z)' => {country: :asc},
           'Country (Z-A)' => {country: :desc}
  end

  # GET /affiliations or /affiliations.json
  def index
    @search = AffiliationSearch.new(params) # initializes search object from request params
    @affiliations = @search.result.paginate(:page => params[:page], :per_page => 10)
    @affi_data = Section.where("obj_name = 'Affiliations'")[0] # get affilitions config data from controller
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

  # download country stats
  def ctry_affi_count
    ctry_affi_stats = InstCtryStat.all.order('inst_count desc').collect{|ca| [ca.country, ca.inst_count, ca.res_count, ca.pub_count]}
    theme_csv = get_csv(['country','institutions','researchers','collaborations'], ctry_affi_stats)
    send_data(theme_csv, 
              :type => 'text/plain', :disposition => 'attachment', :filename => 'ukch_ctry_stats.csv')
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
