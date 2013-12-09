namespace :service do
  # Map alias to real command
  service_cmd = { 'apache' => 'apache2', 'mysql' => 'mysqld', 'varnish' => 'varnish' }

  %w[apache varnish mysql].each do |service|
    namespace service do
      %w[start stop status restart].each do |command|
        desc "#{command} #{service}"
        task command do
          on roles(:all) do |host|
            begin
              puts capture(:sudo, "/etc/init.d/#{service_cmd[service]}", command)
            rescue Exception => error
              # Ignore exceptions as they are thrown if a service is down
            end
          end
        end
      end
    end
  end
end
