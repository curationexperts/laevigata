# deploys to Emory staging-upgrade machine
set :stage, :qa
set :rails_env, 'production'
server 'staging-upgrade-etd.emory.edu', user: 'deploy', roles: [:web, :app, :db]
