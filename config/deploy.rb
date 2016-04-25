set :application, "dump"
set :rvm_ruby_string, `cat .ruby-version`
set :linked_files, %w(config/database.yml config/secrets.yml config/environments/production.rb config/settings/production.yml)
set :linked_dirs, %w(log tmp/pids)

after 'deploy:publishing', 'puma:restart'