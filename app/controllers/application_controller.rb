class ApplicationController < ActionController::Base
  require 'csv'
  before_action :authenticate_user!, except: [:index, :show]
  
  def get_csv(headrs, data_rows)
    CSV.generate do |csv|
      csv << headrs
      data_rows.each do |a_row|
        csv<< a_row
      end
    end
  end
end
