# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "ukchapp"
set :repo_url, "https://github.com/UK-Catalysis-Hub/ukcathubapp.git"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, "/home/deploy/#{fetch :application}"

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads', "storage"

#keep last 5 releases on redeployment
set :keep_releases, 5

# ensure Sidekiq restarts after deployment:
after 'deploy:publishing', 'sidekiq:setup'
after 'deploy:publishing', 'sidekiq:restart'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :sidekiq do
  desc 'Setup Sidekiq systemd service'
  task :setup do
    on roles(:app) do
      execute <<~EOS
#        echo -e "[Unit]\\nDescription=Sidekiq Background Worker\\nAfter=syslog.target network.target\\n\\n[Service]\\nType=simple\\nUser=deploy\\nGroup=deploy\\nWorkingDirectory=#{fetch(:deploy_to)}/current\\nExecStart=/home/deploy/ukchapp/current/bin/bundle exec sidekiq -e production -C #{fetch(:deploy_to)}/current/config/sidekiq.yml\\nRestartSec=5\\nRestart=always\\n\\n[Install]\\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/sidekiq.service
        echo -e "[Unit]\\nDescription=Sidekiq Background Worker\\nAfter=syslog.target network.target\\n[Service]\\nEnvironment="RAILS_ENV=production"\\nExecStart=/home/deploy/.rbenv/shims/bundle exec sidekiq\\nRestart=always\\nUser=deploy\\nWorkingDirectory=/home/deploy/ukchapp/current\\n[Install]\\nWantedBy=multi-user.target"|sudo tee /etc/systemd/system/sidekiq.service
      EOS
      execute 'sudo systemctl daemon-reload'
      execute 'sudo systemctl enable sidekiq'
      execute 'sudo systemctl start sidekiq'
    end
  end

  desc 'Restart Sidekiq'
  task :restart do
    on roles(:app) do
      execute :sudo, 'systemctl restart sidekiq'
    end
  end
end
