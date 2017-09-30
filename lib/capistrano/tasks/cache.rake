set :varnish_cmd,         "/usr/bin/varnishadm"
set :varnish_address,     "127.0.0.1:6082"
set :varnish_ban_pattern, "req.url ~ ^/"

set :opcache_upload_path, -> { release_path.join('apc_clear.php') }
set :drush_cmd,           "drush"

desc "Clear all caches"
task :cache do
 invoke "cache:apc"
 invoke "cache:all"
 invoke "cache:varnish"
end

namespace :cache do
  %w[all themeregistry menu cssjs block modulelist themelist registry token views].each do |action|
    desc "Clear Drupal #{action} cache"
    task action do
      on roles(:all) do |host|
        within current_path do
          execute fetch(:drush_cmd), 'cache-clear', action
        end
      end
    end
  end

  desc "Clear Varnish cache"
  task :varnish do
    on roles(:all) do |host|
      begin
        cmd = "#{fetch(:varnish_cmd)} -T #{fetch(:varnish_address)} 'ban #{fetch(:varnish_ban_pattern)}'"
        execute cmd
      rescue Exception => err
        # Ignore exceptions as they are thrown if varnish is down
        error err
      end
    end
  end

  desc "Clear OPcache"
  task :opcache do
    on roles(:all) do |host|
      # upload as of Capistrano 3.0.1 does not support within.
      contents = %Q[
        <?php
          if (!in_array($_SERVER['REMOTE_ADDR'], array('127.0.0.1', '::1', $_SERVER['SERVER_ADDR']))) return;
          $results = array();

          if (function_exists('apc_clear_cache')) {
            apc_clear_cache();
            apc_clear_cache('user');
            apc_clear_cache('opcode');
            $results[] = 'apc cleared';
          }
          if (function_exists('opcache_reset')) {
            opcache_reset();
            $results[] = 'opcache cleared';
          }
          echo implode('\n', $results);
      ]
      filepath = fetch(:opcache_upload_path)
      begin
        upload! StringIO.new(contents), filepath
        execute :chmod, '644', filepath
        info capture(:curl, '--silent', '-k', '--location', "#{fetch(:app_url)}/apc_clear.php")
      rescue Exception => err
        error err
      ensure
        execute :rm, '-f', filepath
      end
    end
  end

  desc "Clear APC cache"
  task :apc do
    invoke "cache:opcache"
  end
end
