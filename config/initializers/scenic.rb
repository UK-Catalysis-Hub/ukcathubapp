# config/initializers/scenic.rb
# configuration file for scenic_sqlite_adapter

Scenic.configure do |config|
  config.database = Scenic::Adapters::Sqlite.new
end
