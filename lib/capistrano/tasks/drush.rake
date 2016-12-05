set :backup_dir,    "#{fetch(:deploy_to)}/backup"
set :backup_dirs,   %w[db]

set :drush_cmd, "drush"
set :drush_sql_dump_options, "--structure-tables-key=common --gzip"

namespace :drush do
  desc "Set the site offline"
  task :site_offline do
    on roles(:all) do |host|
      within fetch(:web_root, "#{current_path}") do
        execute fetch(:drush_cmd), :vset, 'maintenance_mode', '1', '-y'
      end
    end
  end

  desc "Set the site online"
  task :site_online do
    on roles(:all) do |host|
      within fetch(:web_root, "#{current_path}") do
        execute fetch(:drush_cmd), :vset, 'maintenance_mode', '0', '-y'
      end
    end
  end

  desc "Backup the database"
  task :backupdb do
    on roles(:all) do |host|
      revision = nil
      within repo_path do
        revision = capture(:git, 'rev-parse', :HEAD)[0,5]
      end
      within current_path do
        timestamp = Time.now.strftime('%Y%m%d-%H%M%S')
        file = "#{fetch(:backup_dir)}/db/release-#{timestamp}-#{revision}.sql"
        execute fetch(:drush_cmd), 'sql-dump', fetch(:drush_sql_dump_options), "--result-file=#{file}"
      end
    end
  end

  desc "Import backed up database"
  task :importdb do
    on roles(:all) do |host|
      within current_path do
        dump_files = capture("ls #{fetch(:backup_dir)}/db -1");
        unless dump_files.lines.count
          info "There are no backups which can be restored."
          next
        end
        dump_files.each_line.with_index do |filename, idx|
          puts "[#{idx + 1}] #{filename}"
        end

        ask(:number, "#{dump_files.lines.count}")

        filename = dump_files.lines.to_a[Integer(fetch(:number)) - 1]
        filepath = "#{fetch(:backup_dir)}/db/#{filename}"

        if test("[ -f #{filepath} ]")
          execute :gunzip, '-c', "#{filepath}", "| drush sql-cli"
        else
          error "#{filepath} does not exist."
        end
      end
    end
  end

  desc "Run Drupal database migrations if required"
  task :updatedb do
    on roles(:all) do |host|
      within fetch(:web_root, "#{current_path}") do
        execute fetch(:drush_cmd), :updatedb, '-y'
      end
    end
  end

  desc "Rebuild a Drupal 8 site and clear all its caches."
  task :rebuild do
    on roles(:all) do |host|
      within fetch(:web_root, "#{current_path}") do
        execute fetch(:drush_cmd), :rebuild, '-y'
      end
    end
  end

  desc "Rebuild the registry table and the system table."
  task :registryrebuild do
    on roles(:all) do |host|
      if fetch(:registry_rebuild_path) then
        within "#{current_path}/#{fetch(:registry_rebuild_path)}" do
          execute :php, "registry_rebuild.php"
        end
      else
        within fetch(:web_root, "#{current_path}") do
          execute fetch(:drush_cmd), :rr, '-y'
        end
      end
    end
  end
end

