# deploys to DCE sandbox
set :stage, :aws
set :rails_env, 'production'
server 'emory.curationexperts.com', user: 'deploy', roles: [:web, :app, :db, :resque_pool]
