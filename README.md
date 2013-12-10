Capistrano 3 tasks for drupal sites.

NOTE! These tasks are **NOT** configured for multiple servers!

Tasks
-----
```sh
cap assets:compile                 # Compile assets
cap assets:push                    # Push assets to remote
cap cache                          # Clear all caches
cap cache:all                      # Clear Drupal all cache
cap cache:apc                      # Clear APC cache
cap cache:block                    # Clear Drupal block cache
cap cache:cssjs                    # Clear Drupal cssjs cache
cap cache:menu                     # Clear Drupal menu cache
cap cache:modulelist               # Clear Drupal modulelist cache
cap cache:registry                 # Clear Drupal registry cache
cap cache:themelist                # Clear Drupal themelist cache
cap cache:themeregistry            # Clear Drupal themeregistry cache
cap cache:token                    # Clear Drupal token cache
cap cache:varnish                  # Clear Varnish cache
cap cache:views                    # Clear Drupal views cache
cap deploy:temporary               # Do a quick temporary deploy with only staged files.
cap deploy:check:assets            # Check that assets can compile
cap deploy:check:pushed            # Check if there are unpushed commits
cap deploy:check:sshagent          # Check if a ssh agent is present
cap drush:backupdb                 # Backup the database
cap drush:importdb                 # Import backed up database
cap drush:site_offline             # Set the site offline
cap drush:site_online              # Set the site online
cap drush:updatedb                 # Run Drupal database migrations if required
cap files:pull                     # Pull shared directories (from remote to local)
cap files:push                     # Push drupal sites files (from local to remote)
cap git:create_release             # Copy repo to releases
cap git:tag                        # Place release tag into Git and push it to origin server.
cap local                          # Setup local repository checkout
cap local:environment              # Symlink the checkouts shared folders correctly
cap local:init                     # Initialize git submodules, bower and npm
cap local:precommit                # Setup local grunt pre-commit hook
cap logs:apache_access             # Tail the apache_access file
cap logs:apache_error              # Tail the apache_error file
cap logs:htop                      # View htop
cap logs:varnish                   # Tail the varnish file
cap monit                          # Disply summary of services
cap monit:status                   # Display status of all monit services
cap monit:summary                  # Display summary of all monit services
cap service:apache:restart         # restart apache
cap service:apache:start           # start apache
cap service:apache:status          # status apache
cap service:apache:stop            # stop apache
cap service:mysql:restart          # restart mysql
cap service:mysql:start            # start mysql
cap service:mysql:status           # status mysql
cap service:mysql:stop             # stop mysql
cap service:varnish:restart        # restart varnish
cap service:varnish:start          # start varnish
cap service:varnish:status         # status varnish
cap service:varnish:stop           # stop varnish
cap setup                          # Setup live environment
cap setup:backup_dir               # Scaffold the remote backup directories.
cap setup:config                   # Scaffold the remtoe configuration files
cap setup:environment              # Setup the deploy environments directory structure
cap setup:shared                   # Scaffold the remote shared directory
cap ssh                            # Open a SSH session to remote
```

Variables
---------

This is a list of all variables available and their default values. For example
configurations please see the [example.deploy.rb](https://github.com/generoi/capistrano-tasks/blob/master/example.deploy.rb).

```ruby
# tasks/setup.rake
set :user
set :group

# tasks/drush.rake and tasks/setup.rake
set :backup_dir,    "#{fetch(:deploy_to)}/backup"
set :backup_dirs,   %w[db]

# tasks/setup.rake
set :shared_local_dir
set :shared_settings
set :shared_uploads

# tasks/logs.rake
set :tail_options,            "-n 100 -f"

# tasks/deploy_temporary.rake and tasks/files.rake
set :rsync_options,           "--recursive --times --rsh=ssh --compress --human-readable --progress"

# tasks/drush.rake and tasks/cache.rake
set :drush_cmd,               "drush"
# tasks/drush.rake
set :drush_sql_dump_options,  "--structure-tables-key=common --gzip"

# tasks/cache.rake
set :varnish_cmd,             "/usr/bin/varnishadm"
set :varnish_address,         "127.0.0.1:6082"
set :varnish_ban_pattern,     "req.url ~ ^/"

# tasks/assets.rake
set :assets_compile
set :assets_output
```
