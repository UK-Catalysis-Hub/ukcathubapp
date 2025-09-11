class ApplicationController < ActionController::Base
  require 'csv'

  # Keep CSRF protection for HTML requests
  protect_from_forgery with: :exception

  # Allow API/JSON requests without CSRF token
  skip_before_action :verify_authenticity_token, if: :json_request?

  # Make /api/* default to JSON
  before_action :force_json_for_api_paths

  def get_csv(headrs, data_rows)
    CSV.generate(force_quotes: true) do |csv|
      csv << headrs
      data_rows.each { |a_row| csv << a_row }
    end
  end

  private

  def json_request?
    request.format.json? || request.content_type&.include?('application/json')
  end

  def force_json_for_api_paths
    request.format = :json if request.path.start_with?('/api')
  end
end
