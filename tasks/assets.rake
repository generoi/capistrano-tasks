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
      fetch(:assets_output).each do |dir|
        execute :mkdir, '-p', current_path.join(dir)
        run_locally do
          ssh = SSH.new(host, fetch(:ssh_options))
          execute :rsync, "--rsh=\"ssh #{ssh.args.join(' ')}\"", fetch(:rsync_options), "#{dir}/", "#{ssh.remote}:#{current_path.join(dir)}"
        end
      end
    end
  end
  before :push, 'compile'
end
