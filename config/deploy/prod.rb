# deploys to Emory production machine
set :stage, :prod
set :rails_env, 'production'
server '13.59.122.177', user: 'deploy', roles: [:web, :app, :db]
