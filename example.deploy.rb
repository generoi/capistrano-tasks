set :application,   'application'
set :app_url,       "http://#{fetch(:application)}.com"
set :repo_url,      'git@github.com:example/example.git'
set :branch,        'master'

set :user,          'deploy'
set :group,         'deploy'

set :deploy_to,     "/var/www/#{fetch(:application)}"
# Root directory where backups will be placed.
set :backup_dir,    "#{fetch(:deploy_to)}/backup"
# Backup directories, currently only DB is suppored by drush.rake
set :backup_dirs,   %w[db]
set :log_level,     :info
set :pty,           true

# Location where shared files reside on the development machine.
# This will be appended to :shared_settings and :shared_uploads
set :shared_local_dir,  "/var/www/shared/#{fetch(:application)}"
set :shared_settings,   "sites/default/settings.local.php"
set :shared_uploads,    "sites/default/files"

# Symlink these paths.
set :linked_files,      ["#{fetch(:shared_settings)}", ".htaccess"]
set :linked_dirs,       ["#{fetch(:shared_uploads)}"]

# Flags used by logs-tasks
set :tail_options,            "-n 100 -f"
set :rsync_options,           "--recursive --times --rsh=ssh --compress --human-readable --progress"

set :drush_cmd,               "drush"

# Cache tables should be set as structure tables in drushrc.php so that their
# data will be skipped from dumps.
# $options['structure-tables']['common'] = array('cache', 'cache_*', 'history', 'search_*', 'sessions', 'watchdog');
set :drush_sql_dump_options,  "--structure-tables-key=common --gzip"

set :varnish_cmd,             "/usr/bin/varnishadm"
set :varnish_address,         "127.0.0.1:6082"
set :varnish_ban_pattern,     "req.url ~ ^/"

set :assets_compile,          "grunt build"
set :assets_output,           %w[sites/all/themes/theme/css]

namespace :deploy do
  # Required by capistrano
  task :restart do end
  after :finishing, :drupal_online do
    invoke "drush:site_offline"
    # If you have the CSS/JS assets in the repo (instead of only sass) you can
    # remove this.
    invoke "assets:push"
    invoke "drush:backupdb"
    # If you use APC and not Opcache (PHP 5.5+) use this instead of a graceful restart
    # invoke "cache:apc"
    invoke "service:apache:graceful"
    invoke "cache:all"
    invoke "drush:updatedb"
    invoke "drush:site_online"
    # If you use varnish, uncomment the following
    # invoke "cache:varnish"
  end

  after :rollback, 'cache'
  before :starting, 'deploy:check:pushed'
  # Remove this if you dont use "assets:push"
  before :starting, 'deploy:check:assets'
  before :starting, 'deploy:check:sshagent'
end

