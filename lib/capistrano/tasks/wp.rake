namespace :wp do

  desc 'Clear all caches'
  task :cache do
    invoke 'wp:cache:wpsc'
    invoke 'wp:cache:autoptimize'
  end

  namespace :cache do
    desc 'Flush WP Super Cache'
    task :wpsc do
      on release_roles :all do
        local_path = File.expand_path('../../genero/files/wp-clear-cache.php', __FILE__);
        remote_path = File.join(fetch(:web_root, release_path.join('web')), 'wp-clear-cache.php');
        begin
          upload! local_path, remote_path
          execute :chmod, '644', remote_path
          info capture(:curl, '--silent', "#{fetch(:app_url)}/wp-clear-cache.php?command=wpsc")
        rescue Exception => err
          error err
        ensure
          execute :rm, '-f', remote_path
        end
      end
    end

    desc 'Flush Autoptimize Cache'
    task :autoptimize do
      on release_roles :all do
        local_path = File.expand_path('../../genero/files/wp-clear-cache.php', __FILE__);
        remote_path = File.join(fetch(:web_root, release_path.join('web')), 'wp-clear-cache.php');
        begin
          upload! local_path, remote_path
          execute :chmod, '644', remote_path
          info capture(:curl, '--silent', "#{fetch(:app_url)}/wp-clear-cache.php?command=autoptimize")
        rescue Exception => err
          error err
        ensure
          execute :rm, '-f', remote_path
        end
      end
    end

    desc 'Clean locally compiled dist/ assets.'
    task :dist do
      run_locally do
        execute :rm, '-rf', fetch(:assets_dist_path)
      end
    end
  end
end
