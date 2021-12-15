class AffiliationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :ctry_affi_count]
  before_action :set_affiliation, only: [:show, :edit, :update, :destroy]
  class AffiliationSearch < FortyFacets::FacetSearch
    model 'Affiliation' # which model to search for
    #text  :institution # filter by a generic string entered by the user
    facet  :institution, name: 'Institution'
    facet :country, name: 'Country'
    facet :department, name: 'Department'
    facet :sector, name: 'Sector'
    
    orders 'Institution, Ascendign' => {institution: :asc, department: :asc},
           'Institution, Descending' => {institution: :desc, department: :desc},
           'Country, Ascending' => {country: :asc},
           'Country, Descending' => {country: :desc}
  end

  # GET /affiliations
  # GET /affiliations.json
  def index
    @search = AffiliationSearch.new(params) # initializes search object from request params
    @affiliations = @search.result.paginate(:page => params[:page], :per_page => 10)
  end

  # GET /affiliations/1
  # GET /affiliations/1.json
  def show
  end

  # GET /affiliations/new
  def new
    @affiliation = Affiliation.new
  end

  # GET /affiliations/1/edit
  def edit
  end

  # POST /affiliations
  # POST /affiliations.json
  def create
    @affiliation = Affiliation.new(affiliation_params)

    respond_to do |format|
      if @affiliation.save
        format.html { redirect_to @affiliation, notice: 'Affiliation was successfully created.' }
        format.json { render :show, status: :created, location: @affiliation }
      else
        format.html { render :new }
        format.json { render json: @affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /affiliations/1
  # PATCH/PUT /affiliations/1.json
  def update
    respond_to do |format|
      if @affiliation.update(affiliation_params)
        format.html { redirect_to @affiliation, notice: 'Affiliation was successfully updated.' }
        format.json { render :show, status: :ok, location: @affiliation }
      else
        format.html { render :edit }
        format.json { render json: @affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /affiliations/1
  # DELETE /affiliations/1.json
  def destroy
    @affiliation.destroy
    respond_to do |format|
      format.html { redirect_to affiliations_url, notice: 'Affiliation was successfully destroyed.' }
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
      params.require(:affiliation).permit(:institution, :department, :faculty, :work_group, :country)
    end
end
