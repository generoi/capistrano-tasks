require "#{File.dirname(__FILE__)}/../ssh"

set :tail_options, "-n 100 -f"
set :log_apache_access, "/var/log/apache2/access.log"
set :log_apache_error, "/var/log/apache2/error.log"
set :log_varnish, "/var/log/varnish.log"

namespace :logs do
  log_map = {
    "apache_access" => fetch(:log_apache_access),
    "apache_error" => fetch(:log_apache_error),
    "varnish" => fetch(:log_varnish)
  }
  %w[apache_access apache_error varnish].each do |log|
    desc "Tail the #{log} file"
    task log do
      on roles(:all) do |host|
        cmd = SSH.new(host, fetch(:ssh_options), "tail #{fetch(:tail_options)} #{log_map[log]}").to_s
        info cmd
        exec cmd
      end
    end
  end

  desc "View htop"
  task :htop do
    on roles(:all) do |host|
      cmd = SSH.new(host, fetch(:ssh_options), "htop || top").to_s
      info cmd
      exec cmd.to_s
    end
  end
end

