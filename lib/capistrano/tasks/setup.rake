# Location of root backup directory
set :backup_dir, -> { "#{fetch(:deploy_to)}/backup" }
# Backup directories within.
set :backup_dirs,     %w[db]
set :shared_settings, "sites/default/settings.local.php"

desc "Setup a deploy environment"
task :setup do
  invoke 'setup:environment'
  invoke 'setup:shared'
  invoke 'setup:config'
  invoke 'setup:database'
  invoke 'setup:backup_dir'
end

namespace :setup do
  desc "Setup the deploy environments directory structure"
  task :environment do
    on roles(:app) do |host|
      unless test("[ -d #{fetch(:deploy_to)} ]")
        # Create the project root, to where capistrano will deploy.
        execute :mkdir, fetch(:deploy_to)
        execute :chown, "#{fetch(:user)}:#{fetch(:group)}", fetch(:deploy_to)
        # Make the group sticky, so that the deploy user always has access.
        execute :chmod, 'g+s', fetch(:deploy_to)
        # Create capistranos required directories.
        execute :mkdir, '-p', "#{fetch(:deploy_to)}/{releases,shared}"
        # Tighten server security.
        execute :chmod, '-R', 'o-r', fetch(:deploy_to)
        info "#{fetch(:deploy_to)} created and configured on #{host}"
      else
        info "#{fetch(:deploy_to)} already exists on #{host}"
      end
    end
  end

  # The shared directory contains the linked files and directories (eg.
  # untracked config files).
  desc "Scaffold the deploy environments shared directory."
  task :shared do
    next unless any? :linked_dirs
    on roles(:app) do |host|
      within fetch(:shared_dir) do
        fetch(:linked_dirs).each do |dir|
          execute :mkdir, '-p', shared_path.join(dir)
          execute :chmod, '775', shared_path.join(dir)
          execute :chown, "#{fetch(:user)}:#{fetch(:group)}", shared_path.join(dir)
          # Make the group sticky, so that the deploy user always has access.
          execute :chmod, 'g+s', shared_path.join(dir)
        end
      end
    end
  end

  desc "Scaffold the deploy environments shared files"
  task :config do
    next unless any? :linked_files

    on roles(:app) do |host|
      fetch(:linked_files).each do |file|
        if test("[ -f #{shared_path.join(file)} ]")
          info "Configuration file already exists: #{shared_path.join(file)}"
          next
        end
        # The shared settings file should be scaffolded from user input. The
        # others are simply touched.
        unless file == "#{fetch(:shared_settings)}"
          execute :touch, '-f', shared_path.join(file)
          info "Created new and empty file: #{shared_path.join(file)}"
        end
      end
    end
  end

  desc "Scaffold the deploy environments database settings"
  task :database do
    on roles(:app) do |host|
      if test("[ -f #{shared_path.join(fetch(:shared_settings))} ]")
        info "Configuration file already exists: #{shared_path.join(fetch(:shared_settings))}"
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

      # Scaffold the file.
      execute :mkdir, '-p', File.dirname(shared_path.join(fetch(:shared_settings)))
      upload! StringIO.new(contents), shared_path.join(fetch(:shared_settings))
      execute :chmod, '0664', shared_path.join(fetch(:shared_settings))
      info "Scaffolded configuration file: #{shared_path.join(fetch(:shared_settings))}"

      puts "Do you want to scaffold the database?"
      ask(:verification, 'y')

      if fetch(:verification) == 'y'
        # Create the database if needed.
        begin
          create_db(
            fetch(:database),
            fetch(:username),
            fetch(:password),
            'utf8',
            'utf8_general_ci'
          )
        rescue Exception => err
          error "Was not able to create the database."
          error err
          next
        end
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
end
