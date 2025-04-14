class CrPublicationsController < ApplicationController
  before_action :set_cr_publication, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /cr_publications or /cr_publications.json
  def index
    @cr_publications = CrPublication.all
  end

  # GET /cr_publications/1 or /cr_publications/1.json
  def show
  end

  # GET /cr_publications/new
  def new
    @cr_publication = CrPublication.new
  end

  # GET /cr_publications/1/edit
  def edit
  end

  # POST /cr_publications or /cr_publications.json
  def create
    @cr_publication = CrPublication.new(cr_publication_params)

    respond_to do |format|
      if @cr_publication.save
        format.html { redirect_to @cr_publication, notice: "Cr publication was successfully created." }
        format.json { render :show, status: :created, location: @cr_publication }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cr_publication.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cr_publications/1 or /cr_publications/1.json
  def update
    respond_to do |format|
      if @cr_publication.update(cr_publication_params)
        format.html { redirect_to @cr_publication, notice: "Cr publication was successfully updated." }
        format.json { render :show, status: :ok, location: @cr_publication }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cr_publication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cr_publications/1 or /cr_publications/1.json
  def destroy
    @cr_publication.destroy!

    respond_to do |format|
      format.html { redirect_to cr_publications_path, status: :see_other, notice: "Cr publication was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cr_publication
      @cr_publication = CrPublication.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cr_publication_params
      params.require(:cr_publication).permit(:authors, :pub_year, :title, :doi, :awards, :xref_affi, :themes, :status, :note)
    end
end
