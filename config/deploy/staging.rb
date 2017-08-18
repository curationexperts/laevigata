# deploys to Emory Staging machine
set :stage, :staging
set :rails_env, 'production'
server 'staging-etd.library.emory.edu', user: 'deploy', roles: [:web, :app, :db, :resque_pool]
append :linked_files, "config/initializers/hyrax.rb", "config/environments/production.rb"
