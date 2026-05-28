# config/initializers/db_retry.rb
unless ENV["SECRET_KEY_BASE_DUMMY"] || ENV["SKIP_DB_RETRY"]
  Rails.application.config.to_prepare do
    retries = 5
    begin
      ActiveRecord::Base.connection
    rescue
      retries -= 1
      if retries > 0
        sleep 2
        retry
      else
        raise
      end
    end
  end
end
