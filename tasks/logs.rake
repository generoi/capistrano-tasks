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
      on roles(:all) do
        user = host.user + "@" if !host.user.nil?
        exec "ssh -t #{user}#{host.hostname} 'tail #{fetch(:tail_options)} #{log_map[log]}'"
      end
    end
  end

  desc "View htop"
  task :htop do
    on roles(:all) do |host|
      user = host.user + "@" if !host.user.nil?
      exec "ssh -t #{user}#{host.hostname} 'htop'"
    end
  end
end

