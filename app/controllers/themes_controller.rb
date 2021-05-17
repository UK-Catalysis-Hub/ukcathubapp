class ThemesController < ApplicationController
  before_action :set_theme, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show, :themes_count]
  # GET /themes
  # GET /themes.json
  def index
    @themes = Theme.all
  end

  # GET /themes/1
  # GET /themes/1.json
  def show
  end

  # GET /themes/new
  def new
    @theme = Theme.new
  end

  # GET /themes/1/edit
  def edit
  end

  # POST /themes
  # POST /themes.json
  def create
    @theme = Theme.new(theme_params)
    respond_to do |format|
      if @theme.save
        format.html { redirect_to @theme, notice: 'Theme was successfully created.' }
        format.json { render :show, status: :created, location: @theme }
      else
        format.html { render :new }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /themes/1
  # PATCH/PUT /themes/1.json
  def update
    respond_to do |format|
      if @theme.update(theme_params)
        format.html { redirect_to @theme, notice: 'Theme was successfully updated.' }
        format.json { render :show, status: :ok, location: @theme }
      else
        format.html { render :edit }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /themes/1
  # DELETE /themes/1.json
  def destroy
    @theme.destroy
    respond_to do |format|
      format.html { redirect_to themes_url, notice: 'Theme was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # download theme stats
  def themes_count
    theme_pubs = ListTheme.where("NOT (id IN (6,11,14,15))").collect{|th| [th.name, th.article_count, th.phase]}
    theme_csv = get_csv(['name','count','phase'], theme_pubs)
    send_data(theme_csv, 
              :type => 'text/plain', :disposition => 'attachment', :filename => 'ukch_theme_count.txt')
  end 

  private
    require 'csv'
    # Use callbacks to share common setup or constraints between actions.
    def set_theme
      @theme = Theme.find(params[:id])
    end
    
    # Only allow a list of trusted parameters through.
    def theme_params
      params.require(:theme).permit(:short, :name, :lead, :phase, :used)
    end
    
    def get_csv(headrs, pubs)
      CSV.generate do |csv|
        csv << headrs
        pubs.each do |a_pub|
          csv<< a_pub
        end
      end
    end

end
