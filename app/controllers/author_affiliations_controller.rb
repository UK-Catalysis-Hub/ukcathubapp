class AuthorAffiliationsController < ApplicationController
  before_action :set_author_affiliation, only: [:show, :edit, :update, :destroy]

  # GET /author_affiliations
  # GET /author_affiliations.json
  def index
    @author_affiliations = AuthorAffiliation.all
  end

  # GET /author_affiliations/1
  # GET /author_affiliations/1.json
  def show
  end

  # GET /author_affiliations/new
  def new
    @author_affiliation = AuthorAffiliation.new
  end

  # GET /author_affiliations/1/edit
  def edit
  end

  # POST /author_affiliations
  # POST /author_affiliations.json
  def create
    @author_affiliation = AuthorAffiliation.new(author_affiliation_params)

    respond_to do |format|
      if @author_affiliation.save
        format.html { redirect_to @author_affiliation, notice: 'Author affiliation was successfully created.' }
        format.json { render :show, status: :created, location: @author_affiliation }
      else
        format.html { render :new }
        format.json { render json: @author_affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /author_affiliations/1
  # PATCH/PUT /author_affiliations/1.json
  def update
    respond_to do |format|
      if @author_affiliation.update(author_affiliation_params)
        format.html { redirect_to @author_affiliation, notice: 'Author affiliation was successfully updated.' }
        format.json { render :show, status: :ok, location: @author_affiliation }
      else
        format.html { render :edit }
        format.json { render json: @author_affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /author_affiliations/1
  # DELETE /author_affiliations/1.json
  def destroy
    @author_affiliation.destroy
    respond_to do |format|
      format.html { redirect_to author_affiliations_url, notice: 'Author affiliation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author_affiliation
      @author_affiliation = AuthorAffiliation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def author_affiliation_params
      params.require(:author_affiliation).permit(:author_id, :name, :add_01, :add_02, :add_03, :add_04, :add_05, :country)
    end
end
