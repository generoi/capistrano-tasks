desc "Setup your local repository checkout"
task :local do
  invoke 'local:environment'
  invoke 'local:githooks'
  invoke 'local:init'
end
namespace :local do
  # Only used on shared development environments.
  # Symlinks your checkouts settings, and uploads directory with a cross-user
  # shared.
  desc "Symlink the checkouts shared folders correctly"
  task :environment do
    next if fetch(:shared_local_dir).nil?
    next if fetch(:shared_uploads).nil?
    next if fetch(:shared_settings).nil?

    run_locally do
      unless test("[ -d #{fetch(:shared_local_dir)}/#{fetch(:shared_uploads)} ]")
        execute :mkdir, '-m', '2777', '-p', "#{fetch(:shared_local_dir)}/#{fetch(:shared_uploads)}"
      end
      unless test("[ -f #{fetch(:shared_local_dir)}/#{fetch(:shared_settings)} ]")
        execute :touch, '-f', "#{fetch(:shared_local_dir)}/#{fetch(:shared_settings)}"
      end
      unless test("[ -d #{fetch(:shared_uploads)} ]")
        execute :ln, '-sf', "#{fetch(:shared_local_dir)}/#{fetch(:shared_uploads)}", "#{fetch(:shared_uploads)}"
      end
      execute :cp, '-f', "#{fetch(:shared_local_dir)}/#{fetch(:shared_settings)}", "#{fetch(:shared_settings)}"
    end
  end

  # Create a git commit hook which runs grunt lint.
  desc "Setup local git hooks (if available)"
  task :githooks do
    run_locally do
      if test("[ -f .git/hooks/pre-commit ]")
        info "Hook already exists: .git/hooks/pre-commit"
        next
      end
      if test("[ -f .git-hooks/install.sh ]")
        exec ".git-hooks/install.sh"
        info "Installed git hooks."
        next
      end
      info "No hook available. You should probably setup this repo to use https://github.com/generoi/git-hooks"
    end
  end

  # Fetch all 3rd party submodules.
  desc "Initialize git submodules, bower and npm"
  task :init do
    run_locally do
      execute :npm, :install if test("[ -f package.json ]")
      execute :bower, :install if test("[ -f bower.json ]")
      execute :git, :submodule, :update, '--init'
    end
  end
end
