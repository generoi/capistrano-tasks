set :backup_dir,    "#{fetch(:deploy_to)}/backup"
set :backup_dirs,   %w[db]

desc "Setup live environment"
task :setup do
  invoke "setup:environment"
end

namespace :setup do
  desc "Setup the deploy environments directory structure"
  task :environment do
    on roles(:app) do |host|
      unless test("[ -d #{fetch(:deploy_to)} ]")
        execute :mkdir, fetch(:deploy_to)
        execute :chown, "#{fetch(:user)}:#{fetch(:group)}", fetch(:deploy_to)
        execute :chmod, 'g+s', fetch(:deploy_to)
        execute :mkdir, '-p', "#{fetch(:deploy_to)}/{releases,shared}"
        execute :chmod, '-R', 'o-r', fetch(:deploy_to)
        info "#{fetch(:deploy_to)} created and configured on #{host}"
      else
        info "#{fetch(:deploy_to)} already exists on #{host}"
      end
    end
  end

  desc "Scaffold the remote shared directory"
  task :shared do
    next unless any? :linked_dirs
    on roles(:app) do |host|
      within fetch(:shared_dir) do
        fetch(:linked_dirs).each do |dir|
          execute :mkdir, '-p', shared_path.join(dir)
          execute :chmod, '777', shared_path.join(dir)
        end
      end
    end
  end

  desc "Scaffold the remtoe configuration files"
  task :config do
    next unless any? :linked_files

    on roles(:app) do |host|
      fetch(:linked_files).each do |file|
        unless file == "#{fetch(:shared_settings)}"
          execute :touch, '-f', shared_path.join(file)
          info "Created new and empty file: #{shared_path.join(file)}"
          next
        end

        if test("[ -f #{shared_path.join(file)} ]")
          info "Configuration file already exists: #{shared_path.join(file)}"
          next
        end

        ask(:database, "#{fetch(:application)}")
        ask(:username, "#{fetch(:application)}")
        ask(:password, "")

        contents = %Q[
          <?php

          $databases = array(
            'default' => array(
              'default' => array(
              'database' => '#{fetch(:database)}',
              'username' => '#{fetch(:username)}',
              'password' => '#{fetch(:password)}',
              'host' => 'localhost',
              'port' => '',
              'driver' => 'mysql',
              'prefix' => '',
              ),
            ),
          );
        ]
        execute :mkdir, '-p', File.dirname(shared_path.join(file))
        upload! StringIO.new(contents), shared_path.join(file)
        info "Scaffolded configuration file: #{shared_path.join(file)}"
      end
    end
  end

  desc "Scaffold the remote backup directories."
  task :backup_dir do
    next if fetch(:backup_dir).nil?
    next unless any? :backup_dirs

    on roles(:app) do |host|
      fetch(:backup_dirs).each do |dir|
        next if test("[ -d #{fetch(:backup_dir)}/#{dir} ]")
        execute :mkdir, '-p', "#{fetch(:backup_dir)}/#{dir}"
      end
    end
  end

  after :environment, 'setup:shared'
  after :environment, 'setup:config'
  after :environment, 'setup:backup_dir'
end
