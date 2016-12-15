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
end
