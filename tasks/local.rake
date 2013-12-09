desc "Setup local repository checkout"
task :local do
  invoke "setup:local:environment"
end
namespace :local do
  desc "Symlink the checkouts shared folders correctly"
  task :environment do
    next if fetch(:shared_local_dir).nil?
    next if fetch(:shared_uploads).nil?
    next if fetch(:shared_settings).nil?

    run_locally do
      unless test("[ -d #{fetch(:shared_local_dir)}/#{fetch(:shared_uploads)} ]")
        execute :mkdir, '-p', "#{fetch(:shared_local_dir)}/#{fetch(:shared_uploads)}"
      end
      unless test("[ -f #{fetch(:shared_local_dir)}/#{fetch(:shared_settings)} ]")
        execute :touch, '-f', "#{fetch(:shared_local_dir)}/#{fetch(:shared_settings)}"
      end
      execute :ln, '-sf', "#{fetch(:shared_local_dir)}/#{fetch(:shared_uploads)}", "#{fetch(:shared_uploads)}"
      execute :ln, '-sf', "#{fetch(:shared_local_dir)}/#{fetch(:shared_settings)}", "#{fetch(:shared_settings)}"
    end
  end

  desc "Setup local grunt pre-commit hook"
  task :precommit do
    run_locally do
      unless test("[ -f Gruntfile.js ]")
        info "Missing Gruntfile.js in project root."
        next
      end
      if test("[ -f .git/hooks/pre-commit ]")
        info "Hooks already exists: .git/hooks/pre-commit"
        next
      end
      execute "echo -e \"#/bin/sh\\ngrunt lint\" >| .git/hooks/pre-commit"
      execute :chmod, '+x', '.git/hooks/pre-commit'
    end
  end
  after :environment, 'setup:local:precommit'
end
