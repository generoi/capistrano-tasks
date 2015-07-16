Capistrano 3 tasks for our drupal environments.

NOTE! These tasks are **NOT** configured for multiple roles!

Run `cap -T` to display all available tasks.

Development environment
-----------------------

> Located on your own machine but running inside a virtual machine.

###### Dependencies:

**These you must install by yourself.**

On OSX you can install them with homebrew using `make install-dep-osx`

- Ansible
- Vagrant (with virtualbox)
- Composer
- Drush version 6.x (recommeded to install it through composer)
- GnuPG (osx)

#### Setup

Fetch the code from github, the files and the latest database from production.

_Note that capistrano tasks should always run from within the virtual machine._

```sh
git clone --recursive git@github.com:generoi/<PROJECT>.git

# Check dependencies and install/update your virtual machine.
make install

# This automatically runs the following tasks:
# - make vm-update
# - make vm-install
# - make local-install
# - make dev-install
# - make staging-ssh-copy-id

# If you have access to the production environment from the staging
# environment, you can use:
make production-ssh-copy-id

# Import the database from the production environment.
drush sql-sync @production @dev

# Import the files from the production environment.
# NOTE: Drush rsync requires that one of the targets is local, which is why
# we need to ssh into dev first.
drush @dev ssh 'drush core-rsync @production:%files @self:%files'
```

#### Start coding

1. Make sure your VM is running: `vagrant up`
2. Open the git project in your favorit editor (locally, the files will be
   synced to the VM automatically).
3. Install a [livereload extension](http://livereload.com/extensions/).
4. Run `grunt watch` or `gulp watch` on the virtual machine to automatically
   compile assets and refresh your browser when a file changes.
5. Start coding by opening http://`<PROJECT>.dev` in your browser.

_All git, cap, and drush commands should ideally be run within the virtual
machine. Some (such as drush) work on your local environment however._

##### XDebug with Sublime Text 3

1. Make sure you have [Package Control](https://packagecontrol.io/installation) installed.
2. Install `xdebug client` by going to `tools > command palette > install package > xdebug client`.
3. Configure xdebug in sublime for the project with the following `*.sublime-project` settings.

    ```json
    {
      "folders": [
        {
          "follow_symlinks": true,
          "path": "."
        }
      ],
      "settings": {
        "xdebug": {
          "url": "http://<PROJECT>.dev/",
          "path_mapping": {
            "/var/www/drupal": "/Users/oxy/Projects/Genero/<PROJECT>"
          }
        }
      }
    }
    ```

4. Add a breakpoint and start debugging.

##### XHProf

1. Visit `/admin/config/development/` and enable XHProf.
2. Visit any page you want to profile and look for the XHProf link at the bottom of the page.

XHProf results are at: `http://xhprof.<project>.dev`.

##### LiveReload

1. Install the [browser extension](http://go.livereload.com/extensions).
2. Enable the extension on said page.
3. Run `grunt watch` to trigger livereload when css/js/images changes.

In case you want to use live reloading on mobile devices, look into using the
[LiveReload Drupal module](https://www.drupal.org/project/livereload).

#### Deploy

Note that all `cap` commands must run from within the virtual machine (`vagrant ssh`).
Grunt tasks can only run locally if you install it yourself.

```sh
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

#### Drupal

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
```

#### Drush

```sh
# Check the status of the production site.
drush @production status

# Set the production site into maintenance mode.
drush @production offline
drush @production online

# Import the production database into the virtualmachine.
drush sql-sync @production @dev

# Import the production environment files into the staging environment.
# NOTE: Drush rsync requires that one of the target be local, which is why we
# ssh into staging first (production wouldn't have access to the staging
# environment).
drush @staging ssh 'drush core-rsync @production:%files @self:%files'

# Save a dump of the production database to the local machine.
drush sql-dump @production >| dump.sql
```

#### Clear caches

```sh
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

#### Logs and services

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

Staging environment
-------------------

> Located on _minasanor.genero.fi_, within /var/www/staging/`<PROJECT>` as a
> capistrano target (setup using `current`, `release`, etc folders).

#### Setup

1. Configure the capistrano settings for staging in `config/deploy/staging.rb`
2. Scaffold the capistrano folder structure by running the following from **your own development machine**.

    ```sh
    make staging-install

    # This automatically runs the following commands:
    # - make staging-ssh-copy-id
    # - cap staging setup
    # - cap staging deploy

    # Import the database from the production environment.
    drush sql-sync @production @staging

    # Import the files from the production environment.
    # NOTE: Drush rsync requires that one of the targets is local, which
    # is why we need to ssh into staging env first.
    drush @staging ssh 'drush core-rsync @production:%files @self:%files'
    ```

3. You might have to edit the `.htaccess` file.
4. Done.

Production
----------

> Located on the live server.

#### Setup

1. Setup the environment (apache, php, apc/opcache, varnish, squid, memcached, etc.)
2. Setup the deploy user according to [Capistrano's guides](http://capistranorb.com/documentation/getting-started/authentication-and-authorisation/)
3. Configure the capistrano settings for production: `config/deploy/production.rb`
4. Scaffold the capistrano folder structure by running the following from **your own development machine**.

    ```sh
    cap production setup
    ```

5. Probably not done, you should probably update this readme with whatever
   issues you found :)
