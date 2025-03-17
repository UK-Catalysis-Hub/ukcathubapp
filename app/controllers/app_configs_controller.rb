class AppConfigsController < ApplicationController
  
  # GET /app_configs/1/edit
  def edit
    @app_config = AppConfig.first || AppConfig.new
  end

  # PATCH/PUT /app_configs/1 or /app_configs/1.json
  def update
    @app_config = AppConfig.first || AppConfig.new(app_config_params)

    respond_to do |format|
      if @app_config.update(app_config_params)
        format.html { redirect_to @app_config, notice: "App config was successfully updated." }
        format.json { render :edit, status: :ok, location: @app_config }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @app_config.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def app_config_params
      params.require(:app_config).permit(:title, :browser_tab_name, :organisation_id, 
                                         :contact_id, :contact_email, :award_list, 
                                         :synon_list, :navbar_image, :favicon_image)
    end
end
