# config valid for current version and patch releases of Capistrano
lock "~> 3.11.2"

set :application, "rental"
set :repo_url, "git@github.com:movofilms/rental.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/rental"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/database.yml config/config.yml config/production.sphinx.conf)
# Default value for linked_dirs is []
set :linked_dirs, %w(log tmp/pids tmp/sockets vendor/bundle public/system public/uploads .bundle db/sphinx/production)

# remove :linked_dirs, "public/assets"
# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }
set :npm_flags, '--production'
set :nvm_node, 'v12.11.0'
set :nvm_map_bins, %w{node npm yarn}

# Default value for keep_releases is 5
set :keep_releases, 2
# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :rvm_ruby_version, '2.6.2'
set :rvm_custom_path, '/usr/share/rvm'

set :delayed_job_roles, [:app, :background]

task :default do
  invoke 'delayed_job:restart' if fetch(:delayed_job_default_hooks, true)
end

if Rake::Task.task_defined?('deploy:published')
  after 'deploy:published', 'delayed_job:default'
end

