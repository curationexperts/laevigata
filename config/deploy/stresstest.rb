# deploys to DCE sandbox
set :stage, :stresstest
set :rails_env, 'production'
server 'emory-stress-test.curationexperts.com', user: 'deploy', roles: [:web, :app, :db, :resque_pool]
append :linked_files, "config/initializers/hyrax.rb", "config/environments/production.rb"
