# deploys to Emory production upgrade machine
set :stage, :prod_upgrade
set :rails_env, 'production'
server 'prod-upgrade-etd.emory.edu', user: 'deploy', roles: [:web, :app, :db]
