namespace :assets do
  desc "Compile assets"
  task :compile do
    next if fetch(:assets_compile).nil?
    run_locally do
      execute fetch(:assets_compile)
    end
  end

  desc "Push assets to remote"
  task :push do
    next unless any? :assets_output
    run_locally do
      roles(:all).each do |host|
        fetch(:assets_output).each do |path|
          ssh = SSH.new(host, fetch(:ssh_options))
          path = path.chomp('/')
          source = File.directory?(path) ? "#{path}/" : path
          destination = release_path.join(path)
          execute :rsync, "--rsh=\"ssh #{ssh.args.join(' ')}\"", fetch(:rsync_options), "#{source}", "#{ssh.remote}:#{destination}"
        end
      end
    end
  end
  before :push, 'compile'
end
