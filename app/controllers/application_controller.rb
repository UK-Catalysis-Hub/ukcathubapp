class ApplicationController < ActionController::Base
  require 'csv'

  # 60 requests over 5 minutes allows natural bursts but stops heavy scrapers
  rate_limit to: 60, within: 5.minutes,
             name: "global_json_api",
             by: -> { tracking_key_for_unauthenticated_bots }

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
  
  # create a key for tracking bots
  def tracking_key_for_unauthenticated_bots
    # Skip rate limiting entirely if the request is HTML or not an index action
    return nil unless request.format.json? && action_name == "index"

    # CRITICAL: If a user is logged in, skip this strict rate limit
    return nil if current_user.present?

    # Only track unauthenticated guest IPs
    request.remote_ip 
  end
end
