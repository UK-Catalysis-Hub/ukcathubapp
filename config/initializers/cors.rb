Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # tighten this to your React app origin in prod
    origins '*'
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :patch, :put, :delete, :options, :head]
  end
end
