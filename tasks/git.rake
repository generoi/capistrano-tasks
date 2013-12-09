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

  desc 'Copy repo to releases'
  task create_release: :'git:update' do
    on roles(:all) do
      with fetch(:git_environmental_variables) do
        within repo_path do
          execute :git, :clone, '-b', fetch(:branch), '--recursive', '.', release_path
        end
      end
    end
  end
end
