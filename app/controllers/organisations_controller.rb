class OrganisationsController < ApplicationController
  before_action :set_organisation, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: [:index, :show, :facets]
  before_action :normalize_sort_params, only: [:index, :facets]
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


  def normalize_sort_params
    return unless request.format.json? || params[:format] == 'json' || request.path.start_with?('/api/')
    params[:order] ||= params[:sort] if params[:sort].present?
    params[:order] ||= 'Institution (A-Z)'
  end

  # GET /organisations or /organisations.json
  def index
    per_page = (params[:per_page].presence || 10).to_i

    @search = OrganisationSearch.new(params).filter(:active_org).add(1)

    # Start from FortyFacets-filtered relation
    scope = @search.result.active_org

    # Whitelisted, explicit ORDER BY mapping (ensures sort always applies)
    order_clause =
      case params[:order]
      when 'Institution (A-Z)' then { name: :asc }
      when 'Institution (Z-A)' then { name: :desc }
      when 'Country (A-Z)'     then { country: :asc }
      when 'Country (Z-A)'     then { country: :desc }
      else                         { name: :asc } # default
      end

    scope = scope.order(order_clause)

    @organisations = scope.paginate(page: params[:page], per_page: per_page)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          data: @organisations.map { |org|
            {
              id: org.id,
              name: org.name,
              country: org.country,
              city: org.city,
              sector: org.sector,
              affiliations: org.affiliations.count
            }
          },
          meta: {
            pagination: {
              page: (params[:page].presence || 1).to_i,
              per_page: per_page,
              total: scope.except(:offset, :limit).count
            },
            sort: params[:order]
          }
        }
      end
    end
  end

  def facets
    # Keep the same normalized params behavior (before_action does this)
    @search = OrganisationSearch.new(params).filter(:active_org).add(1)

    # Start from filtered relation, then DROP any ordering so DISTINCT/GROUP BY won't error
    base = @search.result.active_org
    base_no_order = base.reorder(nil) # or: base.unscope(:order)

    render json: {
      data: {
        country: {
          total_unique: base_no_order.distinct.count(:country),
          options: base_no_order.distinct.pluck(:country).compact.sort,
          counts: base_no_order.group(:country).count
        },
        sector: {
          total_unique: base_no_order.distinct.count(:sector),
          options: base_no_order.distinct.pluck(:sector).compact.sort,
          counts: base_no_order.group(:sector).count
        }
      }
    }
  end

  
  # GET /organisations/1 or /organisations/1.json
  def show
    respond_to do |format|
      format.html # existing ERB view
      format.json do
        render json: {
          data: {
            id: @organisation.id,
            name: @organisation.name,
            short_name: @organisation.short_name,
            identifier: @organisation.identifier,
            logo: @organisation.logo,
            homepage: @organisation.homepage,
            address_id: @organisation.address_id,
            city: @organisation.city,
            country: @organisation.country,
            region: @organisation.region,
            sector: @organisation.sector,
            affiliations: @organisation.affiliations.count
          }
        }
      end
    end
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
