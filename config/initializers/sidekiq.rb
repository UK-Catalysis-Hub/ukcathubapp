require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.logger = Rails.logger
  #config.logger.formatter = Sidekiq::Logger::Formatters::JSON.new
  config.logger.formatter = proc do |severity,datetime, progname, message|
    "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{progname} #{severity}: #{message}"
  end

  config.logger.level = Logger::DEBUG
  config.on(:startup) do
    schedule_file = Rails.root.join('config', 'sidekiq_schedule.yml')

    if File.exist?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
    end
  end
end
