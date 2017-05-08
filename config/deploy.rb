# config valid only for current version of Capistrano
lock "3.8.1"

set :application, "echoremix"
set :repo_url, "git@github.com:cyrusstoller/EchoRemix.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, proc { ENV["REVISION"] || ENV["BRANCH_NAME"] || "master" }

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
append :linked_files, ".env", "config/puma.rb"

# Default value for linked_dirs is []
append :linked_dirs, *%w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/assets public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rbenv_type, :system
set :rbenv_ruby, "2.3.1"

set :puma_init_active_record, true
set :puma_bind, -> { File.join("unix://#{shared_path}", 'tmp', 'sockets', "#{fetch(:application)}_puma.sock") }
set :puma_workers, 2
set :puma_conf, -> { "#{shared_path}/config/puma.rb" }
