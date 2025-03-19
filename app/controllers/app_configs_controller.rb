class AppConfigsController < ApplicationController


  def edit
    @app_config = AppConfig.first || AppConfig.new
  end

  def update
    @app_config = AppConfig.first || AppConfig.new(app_config_params)
    if @app_config.update(app_config_params)
      redirect_to @app_config, notice: "App config was successfully updated." 
    else
      render :edit, status: :unprocessable_entity
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
