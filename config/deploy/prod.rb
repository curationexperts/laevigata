# deploys to Emory production machine
set :stage, :prod
set :rails_env, 'production'
server 'etd.library.emory.edu', user: 'deploy', roles: [:web, :app, :db, :resque_pool]
append :linked_files, "config/initializers/hyrax.rb", "config/environments/production.rb"
