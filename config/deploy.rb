# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "webhw"
set :repo_url, "git@github.com:minghuiyang1998/webhw.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/webhw"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
set :ssh_options, { :forward_agent => true }


require 'json'

namespace :pm2 do

  def app_status
    within current_path do
      ps = JSON.parse(capture :pm2, :jlist, fetch(:app_command))
      if ps.empty?
        return nil
      else
        # status: online, errored, stopped
        return ps[0]["pm2_env"]["status"]
      end
    end
  end

  def restart_app
    within current_path do
      execute :pm2, :restart, '../ecosystem.config.js', fetch(:app_command)
    end
  end

  def start_app
    within current_path do
      execute :pm2, :start, '../ecosystem.config.js', fetch(:app_command)
    end
  end

  desc 'Restart app gracefully'
  task :restart do
    on roles(:app) do
      case app_status
      when nil
        info 'App is not registerd'
        start_app
      when 'stopped'
        info 'App is stopped'
        restart_app
      when 'errored'
        info 'App has errored'
        restart_app
      when 'online'
        info 'App is online'
        restart_app
      end
    end
  end

end

namespace :deploy do
    desc 'Install node modules'
    task :install_node_modules do
        on roles(:app) do
        within release_path do
            execute :npm, 'install', '-s'
        end
        end
    end

    desc 'Restart application'
    task :restart do
      invoke 'pm2:restart'
    end

    after :publishing, :restart   
end
