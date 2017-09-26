Capistrano 3 tasks used by Genero Wordpress and Drupal sites.

NOTE! These tasks are **NOT** configured for multiple roles!

Run `cap -T` to display all available tasks.

*Note: if comands do not work, run the commands directly through bundle instead:**

```
bundle exec cap production deploy
```

### Dependencies: (these you must install by yourself)

- PHP 5.6+
- Drush 8+ for Drupal specific tasks
- `wp-cli` for a few Wordpress tasks.
- GnuPG (not on osx by default)
- rsync

Development environment
-----------------------

> Located on your own machine but running inside a virtual machine. All the development is done on the host machine, while mysql, apache etc are on the guest machine.


_Note that all of these tasks should run on your local machine._

### Deploy

```sh
# Add your key to the authorization agent for connecting to production.
eval $(ssh-agent -s)
ssh-add

# Deploy to the production environment
cap production deploy

# Deploy to our staging environment
cap staging deploy

# Simply sync our compiled assets (these might be overriden on next deploy)
cap staging assets:push

# Push our local files to staging environment, overriding older files, but
# leaving untouched/unexisting files.
cap staging files:push

# Push git staged files to staging environment. This is simply rsynced and will
# be removed with the next proper deploy. It only exists for you to stop making
# repetitive fix commits. LEARN NOT TO NEED THIS!
cap staging deploy:temporary
```

### Logs and services

```sh
# Tail some logs
cap production logs:apache_access
cap production logs:apache_error
cap production logs:varnish
cap production logs:htop

# Display summary of running services (if monit is setup)
cap production monit:summary
cap production monit:status

# Control services
cap staging service:apache:graceful
cap staging service:mysql:start
cap staging service:varnish:restart

# Open a SSH connectino to production.
cap production ssh
```

### Drupal specific tasks


```sh
# Maintenance mode
cap production drush:offline
cap production drush:online

# Backup database (on the remote host)
cap production drush:backupdb

# Interactively import database (on the remote host)
cap production drush:importdb

# Run database updates
cap production drush:updatedb

# Clear all caches on production.
cap production cache

# Clear all Drupal caches on production.
cap production cache:all

# Clear the varnish cache on production.
cap production cache:varnish

# Clear the APC cache on production (some weird php bugs).
cap production cache:apc

# Clear the asset caches on production.
cap production cache:cssjs
```

### Laravel specific tasks

```sh
# Execute a provided artisan command.
# Replace :command_name with the command to execute
invoke 'laravel:artisan[:command_name]'

# Create a cache file for faster configuration loading
invoke 'laravel:config_cache'

# Create a route cache file for faster route registration
invoke 'laravel:route_cache'

# Create a symbolic link from "public/storage" to "storage/app/public"
invoke 'laravel:storage_link'

# Run the database migrations.
invoke 'laravel:migrate'

# Rollback the last database migration.
invoke 'laravel:migrate_rollback'

```

### Wordpress specific tasks

```sh
# Clear the Timber cache
cap production wp:cache:timber

# Clear the Autoptimize cache
cap production wp:cache:autoptimize

# Clear the WP Super Cache cache
cap production wp:cache:wpsc

# Clear the WP object cache (requires wp-cli)
cap production wp:cache:objectcache

```

Staging environment
-------------------

> Located on _minasanor.genero.fi_, within /var/www/staging/`<PROJECT>` as a
> capistrano target (setup using `current`, `release`, etc folders).

#### Setup

1. Configure the capistrano settings for staging in `config/deploy/staging.rb`
2. Scaffold the capistrano folder structure by running the following from **your own development machine**.

    ```sh
    # Drupal
    cap staging setup

    # Wordpress
    cap staging wp:setup
    ```

3. Done.

Production
----------

> Located on the live server.

#### Setup

1. Setup the environment (apache, php, apc/opcache, varnish, squid, memcached, etc.)
2. Setup the deploy user according to [Capistrano's guides](http://capistranorb.com/documentation/getting-started/authentication-and-authorisation/)
3. Configure the capistrano settings for production: `config/deploy/production.rb`
4. Scaffold the capistrano folder structure by running the following from **your own development machine**.

    ```sh
    # Drupal
    cap production setup

    # Wordpress
    cap production wp:setup
    ```

5. Probably not done, you should update this readme with whatever
   issues you found :)
