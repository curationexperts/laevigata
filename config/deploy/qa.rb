# deploys to Emory qa machine
set :stage, :qa
set :rails_env, 'production'
server 'qa-etd.library.emory.edu', user: 'deploy', roles: [:web, :app, :db]
namespace :deploy do
  after :finishing, :qa_approver_setup do
    on roles(:app) do
      execute "cd #{deploy_to}/current; /usr/bin/env bundle exec rake emory:qa_approver_setup RAILS_ENV=production"
    end
  end
end
