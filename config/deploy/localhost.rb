# deploy to localhost for cap
set :stage, :localhost
set :rails_env, 'production'
server '127.0.0.1', user: 'deploy', roles: [:web, :app, :db]
