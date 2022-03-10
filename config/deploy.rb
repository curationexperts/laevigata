after 'deploy:published', 'laevigata:workflow_setup'
# config valid only for current version of Capistrano
lock ">=3.9.0"

set :application, "laevigata"
set :repo_url, "https://github.com/curationexperts/laevigata.git"
set :deploy_to, '/opt/laevigata'
set :ssh_options, keys: ["laevigata_deploy_rsa"] if File.exist?("laevigata_deploy_rsa")

set :log_level, :debug
set :bundle_flags, '--deployment'
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :keep_releases, 5
set :assets_prefix, "#{shared_path}/public/assets"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

# Default branch is :main
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || ENV['BRANCH'] || 'main'

append :linked_dirs, "config/emory"
append :linked_dirs, "public/assets"
append :linked_dirs, "tmp/pids"
append :linked_dirs, "tmp/cache"
append :linked_dirs, "tmp/sockets"
append :linked_dirs, "log"

append :linked_files, ".env.production"
append :linked_files, "config/secrets.yml"

# We have to re-define capistrano-sidekiq's tasks to work with
# systemctl in production
Rake::Task["sidekiq:stop"].clear_actions
Rake::Task["sidekiq:start"].clear_actions
Rake::Task["sidekiq:restart"].clear_actions
namespace :sidekiq do
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, :sidekiq
    end
  end
  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, :sidekiq
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :sidekiq
    end
  end
end

# Capistrano passenger restart isn't working consistently,
# so restart apache2 after a successful deploy, to ensure
# changes are picked up.
namespace :deploy do
  after :finishing, :restart_apache do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :apache2
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rails, :"schoolie:sitemap"
        end
      end
    end
  end
end
