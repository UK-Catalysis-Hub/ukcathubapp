class OrganisationAliasesController < ApplicationController
  before_action :set_organisation_alias, only: %i[ show edit update destroy ]

  # GET /organisation_aliases or /organisation_aliases.json
  def index
    @organisation_aliases = OrganisationAlias.all
  end

  # GET /organisation_aliases/1 or /organisation_aliases/1.json
  def show
  end

  # GET /organisation_aliases/new
  def new
    @organisation_alias = OrganisationAlias.new
  end

  # GET /organisation_aliases/1/edit
  def edit
  end

  # POST /organisation_aliases or /organisation_aliases.json
  def create
    @organisation_alias = OrganisationAlias.new(organisation_alias_params)

    respond_to do |format|
      if @organisation_alias.save
        format.html { redirect_to @organisation_alias, notice: "Organisation alias was successfully created." }
        format.json { render :show, status: :created, location: @organisation_alias }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @organisation_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organisation_aliases/1 or /organisation_aliases/1.json
  def update
    respond_to do |format|
      if @organisation_alias.update(organisation_alias_params)
        format.html { redirect_to @organisation_alias, notice: "Organisation alias was successfully updated." }
        format.json { render :show, status: :ok, location: @organisation_alias }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @organisation_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisation_aliases/1 or /organisation_aliases/1.json
  def destroy
    @organisation_alias.destroy!

    respond_to do |format|
      format.html { redirect_to organisation_aliases_path, status: :see_other, notice: "Organisation alias was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organisation_alias
      @organisation_alias = OrganisationAlias.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def organisation_alias_params
      params.require(:organisation_alias).permit(:organisation_id, :name, :alias_type, :valid_from, :valid_to, :laguage_code)
    end
end
