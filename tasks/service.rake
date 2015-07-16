namespace :service do
  # Map alias to real command
  service_cmd = { 'apache' => 'apache2', 'mysql' => 'mysqld', 'varnish' => 'varnish' }

  %w[apache varnish mysql].each do |service|
    namespace service do
      %w[start stop status restart graceful].each do |command|
        desc "#{command} #{service}"
        task command do
          on roles(:all) do |host|
            begin
              puts capture(:sudo, "/etc/init.d/#{service_cmd[service]}", command)
            rescue Exception => err
              error err
            end
          end
        end
      end
    end
  end
end
