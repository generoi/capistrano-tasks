set :rsync_options, "--recursive --times --rsh=ssh --compress --human-readable --progress"

namespace :files do
  desc "Pull shared directories (from remote to local)"
  task :pull do
    roles(:all).each do |host|
      user = host.user + "@" if !host.user.nil?
      run_locally do
        fetch(:linked_dirs).each do |dir|
          remote_dir = shared_path.join(dir)
          exec "rsync #{fetch(:rsync_options)} #{user}#{host.hostname}:#{remote_dir}/ #{dir}"
        end
      end
    end
  end

  desc "Push drupal sites files (from local to remote)"
  task :push do
    roles(:all).each do |host|
      user = host.user + "@" if !host.user.nil?
      run_locally do
        fetch(:linked_dirs).each do |dir|
          remote_dir = shared_path.join(dir)
          puts <<-WARN
            Are you sure you want to transfer files from local #{dir}
            to remote #{remote_dir}?

            WARNING this operation is destructive!
          WARN
          puts "Continue with push [y/N]"
          ask(:verification, 'N')
          if fetch(:verification) == 'y'
            exec "rsync #{fetch(:rsync_options)} #{dir}/ #{user}#{host.hostname}:#{remote_dir}"
          else
            info "Skipping push."
          end
        end
      end
    end
  end
end
