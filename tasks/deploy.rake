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

  namespace :check do
    desc "Check if a ssh agent is present"
    task :sshagent do
      run_locally do
        begin
          ssh_agent = capture('ssh-add', '-l')
        rescue
          puts %Q[
            You do not have an identity in your authentication agent.
            Make sure the agent is running and add your key before continuing.

            $ eval `ssh-agent -s`
            $ ssh-add
          ]
          exit 1
        end
      end
    end

    desc "Check that assets can compile"
    task :assets do
      run_locally do
        next if fetch(:assets_compile).nil?
        begin
          execute fetch(:assets_compile)
        rescue
          puts %Q[
            Assets could not be compiles with #{fetch(:assets_compile)}, make sure
            all dependencies are installed.

            If you are using grunt for compilation, you have to run:

            $ npm install
          ]
          exit 1
        end
      end
    end

    desc "Check if there are unpushed commits"
    task :pushed do
      run_locally do
        log = capture(:git, :log, '--pretty="%h: %s"', "origin/#{fetch(:branch)}..HEAD")
        unless log.empty?
          puts %Q[
          The branch is ahead of origin/#{fetch(:branch)} by #{log.lines.count} commits."

          #{log}

          Are you sure you want to continue without pushing these? [Y/n]
          ]
          ask(:verification, 'y')
          unless fetch(:verification) == 'y'
            error "Exiting as there are unpushed commits."
            exit 1
          end
        end
      end
    end
  end
end
