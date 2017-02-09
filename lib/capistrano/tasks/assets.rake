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
    run_locally do
      roles(:all).each do |host|
        fetch(:assets_output).each do |dir|
          ssh = SSH.new(host, fetch(:ssh_options))
          execute :rsync, "--rsh=\"ssh #{ssh.args.join(' ')}\"", fetch(:rsync_options), "#{dir}/", "#{ssh.remote}:#{release_path.join(dir)}"
        end
      end
    end
  end
  before :push, 'compile'
end
