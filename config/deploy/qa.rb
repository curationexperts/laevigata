# deploys to Emory qa machine
set :stage, :qa
set :rails_env, 'production'
server 'qa-etd.library.emory.edu', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, "config/initializers/hyrax.rb"
