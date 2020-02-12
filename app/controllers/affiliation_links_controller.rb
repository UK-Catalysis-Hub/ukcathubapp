class AffiliationLinksController < ApplicationController
  before_action :set_affiliation_link, only: [:show, :edit, :update, :destroy]

  # GET /affiliation_links
  # GET /affiliation_links.json
  def index
    @affiliation_links = AffiliationLink.all
  end

  # GET /affiliation_links/1
  # GET /affiliation_links/1.json
  def show
  end

  # GET /affiliation_links/new
  def new
    @affiliation_link = AffiliationLink.new
  end

  # GET /affiliation_links/1/edit
  def edit
  end

  # POST /affiliation_links
  # POST /affiliation_links.json
  def create
    @affiliation_link = AffiliationLink.new(affiliation_link_params)

    respond_to do |format|
      if @affiliation_link.save
        format.html { redirect_to @affiliation_link, notice: 'Affiliation link was successfully created.' }
        format.json { render :show, status: :created, location: @affiliation_link }
      else
        format.html { render :new }
        format.json { render json: @affiliation_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /affiliation_links/1
  # PATCH/PUT /affiliation_links/1.json
  def update
    respond_to do |format|
      if @affiliation_link.update(affiliation_link_params)
        format.html { redirect_to @affiliation_link, notice: 'Affiliation link was successfully updated.' }
        format.json { render :show, status: :ok, location: @affiliation_link }
      else
        format.html { render :edit }
        format.json { render json: @affiliation_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /affiliation_links/1
  # DELETE /affiliation_links/1.json
  def destroy
    @affiliation_link.destroy
    respond_to do |format|
      format.html { redirect_to affiliation_links_url, notice: 'Affiliation link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_affiliation_link
      @affiliation_link = AffiliationLink.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def affiliation_link_params
      params.require(:affiliation_link).permit(:affiliation_id, :doi, :author_id, :sequence, :address_id)
    end
end
