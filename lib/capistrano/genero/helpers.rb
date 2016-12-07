require 'securerandom'

module Capistrano
  module Genero
    module Helpers

      def create_db(database, username, password, charset, collate)
        execute :mysql, '-u', 'root', '-e', "\"CREATE DATABASE IF NOT EXISTS #{database} CHARACTER SET #{charset} COLLATE #{collate};\""
        execute :mysql, '-u', 'root', '-e', "\"GRANT ALL PRIVILEGES ON #{database}.* TO '#{username}'@'localhost' IDENTIFIED BY '#{password}';\""
        execute :mysql, '-u', 'root', '-e', "\"GRANT ALL PRIVILEGES ON #{database}.* TO '#{username}'@'127.0.0.1' IDENTIFIED BY '#{password}';\""
        execute :mysql, '-u', 'root', '-e', "\"SET PASSWORD FOR '#{username}'@'localhost' = PASSWORD('#{password}');\""
        execute :mysql, '-u', 'root', '-e', "\"SET PASSWORD FOR '#{username}'@'127.0.0.1' = PASSWORD('#{password}');\""
        execute :mysql, '-u', 'root', '-e', "\"FLUSH PRIVILEGES;\""
      end

      def wp_env_contents(database, username, password, host, env, wp_home)
        contents = %Q[
DB_NAME=#{database}
DB_USER=#{username}
DB_PASSWORD=#{password}
DB_HOST=#{host}

WP_ENV=#{env}
WP_HOME=#{wp_home}
WP_SITEURL=${WP_HOME}/wp
# Uncomment for multisite installations.
# DOMAIN_CURRENT_SITE=sage-dev.dev

# Generate your keys here: https://roots.io/salts.html
AUTH_KEY='#{SecureRandom.hex(32)}'
SECURE_AUTH_KEY='#{SecureRandom.hex(32)}'
LOGGED_IN_KEY='#{SecureRandom.hex(32)}'
NONCE_KEY='#{SecureRandom.hex(32)}'
AUTH_SALT='#{SecureRandom.hex(32)}'
SECURE_AUTH_SALT='#{SecureRandom.hex(32)}'
LOGGED_IN_SALT='#{SecureRandom.hex(32)}'
NONCE_SALT='#{SecureRandom.hex(32)}'
        ]
        contents
      end

    end
  end
end
