require 'capistrano/genero/helpers'
include Capistrano::Genero::Helpers

namespace :wp do

  desc 'Clear all caches'
  task :cache do
    invoke 'wp:cache:wpsc'
    invoke 'wp:cache:autoptimize'
  end

  task :setup do
    invoke 'setup:environment'
    invoke 'setup:shared'
    invoke 'wp:setup:database'
    invoke 'setup:config'
    invoke 'setup:backup_dir'
  end

  namespace :setup do
    task :database do
      on roles(:app) do |host|
        if test("[ -f #{shared_path.join(fetch(:shared_settings))} ]")
          info "Configuration file already exists: #{shared_path.join(fetch(:shared_settings))}"
          next
        end

        ask(:database, "#{fetch(:application)}")
        ask(:username, "#{fetch(:application)}")
        ask(:host, "localhost")
        ask(:env, "development")
        ask(:password, "")

        contents = wp_env_contents(
          fetch(:database),
          fetch(:username),
          fetch(:password),
          fetch(:host),
          fetch(:env),
          fetch(:app_url)
        )

        # Scaffold the file.
        execute :mkdir, '-p', File.dirname(shared_path.join(fetch(:shared_settings)))
        upload! StringIO.new(contents), shared_path.join(fetch(:shared_settings))
        execute :chmod, '0664', shared_path.join(fetch(:shared_settings))
        info "Scaffolded configuration file: #{shared_path.join(fetch(:shared_settings))}"

        puts "Do you want to scaffold the database?"
        ask(:verification, 'y')

        if fetch(:verification) == 'y'
          # Create the database if needed.
          begin
            create_db(
              fetch(:database),
              fetch(:username),
              fetch(:password),
              'utf8mb4',
              'utf8mb4_unicode_ci'
            )
          rescue Exception => err
            error "Was not able to create the database."
            error err
            next
          end
        end
      end
    end
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
