class CrAfiliationsController < ApplicationController
  before_action :set_cr_afiliation, only: [:show, :edit, :update, :destroy]

  # GET /cr_afiliations
  # GET /cr_afiliations.json
  def index
    @cr_afiliations = CrAfiliation.all
  end

  # GET /cr_afiliations/1
  # GET /cr_afiliations/1.json
  def show
  end

  # GET /cr_afiliations/new
  def new
    @cr_afiliation = CrAfiliation.new
  end

  # GET /cr_afiliations/1/edit
  def edit
  end

  # POST /cr_afiliations
  # POST /cr_afiliations.json
  def create
    @cr_afiliation = CrAfiliation.new(cr_afiliation_params)

    respond_to do |format|
      if @cr_afiliation.save
        format.html { redirect_to @cr_afiliation, notice: 'Cr afiliation was successfully created.' }
        format.json { render :show, status: :created, location: @cr_afiliation }
      else
        format.html { render :new }
        format.json { render json: @cr_afiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cr_afiliations/1
  # PATCH/PUT /cr_afiliations/1.json
  def update
    respond_to do |format|
      if @cr_afiliation.update(cr_afiliation_params)
        format.html { redirect_to @cr_afiliation, notice: 'Cr afiliation was successfully updated.' }
        format.json { render :show, status: :ok, location: @cr_afiliation }
      else
        format.html { render :edit }
        format.json { render json: @cr_afiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cr_afiliations/1
  # DELETE /cr_afiliations/1.json
  def destroy
    @cr_afiliation.destroy
    respond_to do |format|
      format.html { redirect_to cr_afiliations_url, notice: 'Cr afiliation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cr_afiliation
      @cr_afiliation = CrAfiliation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cr_afiliation_params
      params.require(:cr_afiliation).permit(:name, :article_author_id, :affiliation_id)
    end
end
