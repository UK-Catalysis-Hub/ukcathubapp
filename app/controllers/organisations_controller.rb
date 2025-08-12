class OrganisationsController < ApplicationController
  before_action :set_organisation, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: [:index, :show]
  class OrganisationSearch < FortyFacets::FacetSearch
    model 'Organisation' # which model to search for
    # issue a filter cannot be also a facet, need 'alias'?
    text  :name # filter by a generic string entered by the user
    scope :active_org, name: "active"
    
    facet :country, name: 'Country', order: Proc.new { |country| country }
    facet :sector, name: 'Sector', order: Proc.new { |sector| sector }
    
    orders 'Institution (A-Z)' => {name: :asc},
           'Institution (Z-A)' => {name: :desc},
           'Country (A-Z)' => {country: :asc},
           'Country (Z-A)' => {country: :desc}
  end

  # GET /organisations or /organisations.json
  def index
    @search = OrganisationSearch.new(params).filter(:active_org).add(1) # initializes search object from request params
    @organisations = @search.result.active_org.paginate(:page => params[:page], :per_page => 10)
  end
  
  # GET /organisations/1 or /organisations/1.json
  def show
  end

  # GET /organisations/new
  def new
    @organisation = Organisation.new
  end

  # GET /organisations/1/edit
  def edit
  end

  # POST /organisations or /organisations.json
  def create
    @organisation = Organisation.new(organisation_params)

    respond_to do |format|
      if @organisation.save
        format.html { redirect_to @organisation, notice: "Organisation was successfully created." }
        format.json { render :show, status: :created, location: @organisation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organisations/1 or /organisations/1.json
  def update
    respond_to do |format|
      if @organisation.update(organisation_params)
        format.html { redirect_to @organisation, notice: "Organisation was successfully updated." }
        format.json { render :show, status: :ok, location: @organisation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisations/1 or /organisations/1.json
  def destroy
    @organisation.destroy!

    respond_to do |format|
      format.html { redirect_to organisations_path, status: :see_other, notice: "Organisation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.s
    def set_organisation
      @organisation = Organisation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def organisation_params
      params.require(:organisation).permit(:name, :short_name, :identifier, :logo, :homepage, :address_id, :city, :country, :sector,:region)
    end
end
