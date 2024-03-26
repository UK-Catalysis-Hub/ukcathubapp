class ApplicationController < ActionController::Base
  require 'csv' 
  def get_csv(headrs, data_rows)
    CSV.generate(force_quotes: true) do |csv|
      csv << headrs
      data_rows.each do |a_row|
        csv<< a_row
      end
    end
  end
end
