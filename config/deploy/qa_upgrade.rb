# deploys to Emory qa-upgrade machine
set :stage, :qa_upgrade
set :rails_env, 'production'
server 'qa-upgrade-etd.emory.edu', user: 'deploy', roles: [:web, :app, :db]
