namespace :laravel do

  desc "Execute a provided artisan command."
  task :artisan, [:command_name] do |_t, args|
    ask(:cmd, "list") # Ask only runs if argument is not provided
    command = args[:command_name] || fetch(:cmd)

    on roles fetch(:laravel_roles) do
      within release_path do
        execute :php, :artisan, command, *args.extras, fetch(:laravel_artisan_flags)
      end
    end

    # Enable task artisan to be ran more than once
    Rake::Task["laravel:artisan"].reenable
  end

  desc "Create a cache file for faster configuration loading."
  task :config_cache do
    Rake::Task["laravel:artisan"].invoke("config:cache")
  end

  desc "Create a route cache file for faster route registration."
  task :route_cache do
    Rake::Task["laravel:artisan"].invoke("route:cache")
  end

  desc "Create a symbolic link from \"public/storage\" to \"storage/app/public.\""
  task :storage_link do
    Rake::Task["laravel:artisan"].invoke("storage:link")
  end

  desc "Run the database migrations."
  task :migrate do
    laravel_roles = fetch(:laravel_roles)
    laravel_artisan_flags = fetch(:laravel_artisan_flags)

    set(:laravel_roles, fetch(:laravel_migration_roles))
    set(:laravel_artisan_flags, fetch(:laravel_migration_artisan_flags))

    Rake::Task["laravel:artisan"].invoke(:migrate)

    set(:laravel_roles, laravel_roles)
    set(:laravel_artisan_flags, laravel_artisan_flags)
  end

  desc "Rollback the last database migration."
  task :migrate_rollback do
    laravel_roles = fetch(:laravel_roles)
    laravel_artisan_flags = fetch(:laravel_artisan_flags)

    set(:laravel_roles, fetch(:laravel_migration_roles))
    set(:laravel_artisan_flags, fetch(:laravel_migration_artisan_flags))

    Rake::Task["laravel:artisan"].invoke("migrate:rollback")

    set(:laravel_roles, laravel_roles)
    set(:laravel_artisan_flags, laravel_artisan_flags)
  end
end
