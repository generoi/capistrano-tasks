namespace :git do
  desc "Place release tag into Git and push it to origin server."
  task :tag do
    run_locally do
      user  = capture(:git, :config, '--get', 'user.name')
      email = capture(:git, :config, '--get', 'user.email')
      revision = capture(:git, 'rev-parse', :HEAD)
      timestamp = Time.now.strftime('%Y%m%d-%H%M%S')
      tag = "#{fetch(:stage)}_#{timestamp}"
      execute :git, :tag, tag, revision, '-m', "\"Deployed by #{user} <#{email}>\""
      execute :git, :push, :origin, :tag, tag
    end
  end

  desc "Check if there are unpushed commits"
  task :check_pushed do
    run_locally do
      log = capture(:git, :log, '--pretty="%h: %s"', "origin/#{fetch(:branch)}..HEAD")
      unless log.empty?
        puts "The branch is ahead of origin/#{fetch(:branch)} by #{log.lines.count} commits."
        puts
        puts log
        puts
        puts "Are you sure you want to continue without pushing these? [Y/n]"
        ask(:verification, 'y')
        unless fetch(:verification) == 'y'
          error "Exiting as there are unpushed commits."
          exit 1
        end
      end
    end
  end

  desc "Copy repo to releases"
  task create_release: :'git:update' do
    on roles(:all) do
      with fetch(:git_environmental_variables) do
        within repo_path do
          execute :git, :clone, '-b', fetch(:branch), '--single-branch', '--recursive', '.', release_path
        end
      end
    end
  end
end
