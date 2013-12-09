set :rsync_options, "--recursive --times --rsh=ssh --compress --human-readable --progress"

namespace :deploy do
  desc "Do a quick temporary deploy with only staged files."
  task :temporary do
    on roles(:all) do |host|
      run_locally do
        user = host.user + "@" if !host.user.nil?
        files = capture(:git, :diff, '--name-only', "origin/#{fetch(:branch)}")
        puts <<-WARN
          Are you sure you want to transfer files from local
          to remote #{current_path}?

          Files which will be transfered are (the entire file and not only the
          staged diff will be transfered):
          #{files}
        WARN
        puts "Continue with transfer [y/N]"
        ask(:verification, 'N')
        if fetch(:verification) == 'y'
          exec "rsync #{fetch(:rsync_options)} #{files} #{user}#{host.hostname}:#{current_path}"
        else
          info "Skipping deploy."
        end
      end
    end
  end
end
