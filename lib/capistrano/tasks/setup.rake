require_relative "helper"

desc "Setup the server"
task :setup do
  invoke "deploy:check:directories"
  invoke "setup:shared_config"
  invoke "env:upload"
  invoke "puma:config"
  invoke "setup:nginx"
  invoke "setup:logrotation"
  invoke "puma:monit:config"
end

namespace :setup do
  desc "Setup shared config file"
  task :shared_config do
    on roles(fetch(:puma_role, :app)) do |host|
      execute :mkdir, "-p", "#{shared_path}/config"
      execute :mkdir, "-p", "#{shared_path}/log"
    end
  end

  desc "Setup nginx"
  task :nginx do
    invoke "puma:nginx_config"

    on roles(fetch(:puma_nginx, :web)) do |role|
      sudo :service, "nginx", "reload"
    end
  end

  desc "adding the logrotation config"
  task :logrotation do
    on roles(fetch(:puma_role, :app)) do |host|
      info "copying the puma logrotate.d conf file"
      logrotate_conf = ERB.new(template("puma_log_rotate.conf.erb")).result(binding)

      tmp_path = Pathname.new("#{shared_path}/config/puma_log_rotate.conf")
      final_path = "/etc/logrotate.d/puma_#{fetch(:application)}"

      upload! StringIO.new(logrotate_conf), tmp_path
      execute :chmod, 644, tmp_path
      execute :sudo, :mv, tmp_path, final_path
      execute :sudo, :chown, "root.root", final_path

      # set permissions
      log_path = Pathname.new("#{shared_path}/log")
      execute :chmod, 750, log_path
    end
  end
end
