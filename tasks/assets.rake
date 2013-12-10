namespace :assets do
  desc "Compile assets"
  task :compile do
    next if fetch(:assets_compile).nil?
    run_locally do
      puts capture(fetch(:assets_compile))
    end
  end

  desc "Push assets to remote"
  task :push do
    next unless any? :assets_output
    on roles(:all) do |host|
      user = host.user + "@" if !host.user.nil?
      fetch(:assets_output).each do |dir|
        execute :mkdir, '-p', current_path.join(dir)
        run_locally do
          execute :rsync, fetch(:rsync_options), "#{dir}/", "#{user}#{host.hostname}:#{current_path.join(dir)}"
        end
      end
    end
  end
  before :push, 'compile'
end
