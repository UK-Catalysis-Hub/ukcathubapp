class ApplicationController < ActionController::Base
  
  require 'csv'
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, except: [:index, :show]
  
  def get_csv(headrs, data_rows)
    CSV.generate(force_quotes: true) do |csv|
      csv << headrs
      data_rows.each do |a_row|
        csv<< a_row
      end
    end
  end
  
  def configure_permitted_parameters
    attributes = [:username, :email, :password, :password_confirmation]
    devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    devise_parameter_sanitizer.permit(:account_update, keys: attributes)
  end
  
end
