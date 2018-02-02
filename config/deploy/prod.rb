# deploys to Emory production machine
set :stage, :prod
set :rails_env, 'production'
server '13.59.122.177', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, "config/initializers/hyrax.rb", "config/environments/production.rb"
