# deploys to Emory Staging machine
set :stage, :staging
set :rails_env, 'production'
server 'staging-etd.library.emory.edu', user: 'deploy', roles: [:web, :app, :db]
