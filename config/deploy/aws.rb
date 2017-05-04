# deploys to DCE sandbox
set :stage, :aws
set :rails_env, 'production'
server 'emory.curationexperts.com', user: 'deploy', roles: [:web, :app, :db, :resque_pool]
append :linked_files, "config/initializers/hyrax.rb", "config/environments/production.rb"
