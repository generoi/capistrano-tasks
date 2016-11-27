set :wp_cache_dir, "web/app/cache"

namespace :wp do

  desc "Clear all caches"
  task :cache do
    invoke "cache:flush-wpcc"
    invoke "cache:flush-autoptimize"
  end

  namespace :cache do
    desc 'Flush WP Super Cache'
    task 'flush-wpcc' do
      on roles(:app) do
        within current_path do
          %w[supercache blogs meta].each do |dir|
            execute :rm, '-rf', "#{fetch(:wp_cache_dir)}/#{dir}/*"
          end
          execute :rm, '-f', 'web/app/cache/wp-cache-*'
        end
      end
    end

    desc 'Flush Autoptimize Cache'
    task 'flush-autoptimize' do
      on roles(:app) do
        within current_path do
          execute :rm, '-rf', "#{fetch(:wp_cache_dir)}/autoptimize/*"
        end
      end
    end

    desc 'Clean locally compiled dist/ assets.'
    task 'flush-dist' do
      run_locally do
        execute :rm, '-rf', fetch(:assets_dist_path)
      end
    end
  end
end
