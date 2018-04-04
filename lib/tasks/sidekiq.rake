# Usage: bundle exec rake sidekiq:restart RAILS_ENV=<environment name>

namespace :sidekiq do
  sidekiq_pid_file = Rails.root + 'tmp/pids/sidekiq-0.pid'
  sidekiq_log_file = Rails.root + 'log/sidekiq.log'

  desc "Sidekiq stop"
  task :stop do
    puts "--- Trying to stop Sidekiq Now ---"
    if File.exist?(sidekiq_pid_file)
      puts "Stopping sidekiq now #PID-#{File.readlines(sidekiq_pid_file).first}..."
      system "sidekiqctl stop #{sidekiq_pid_file}" # stops sidekiq process here
    else
      puts "--- Sidekiq Not Running ---"
    end
  end

  desc "Sidekiq start"
  task :start do
    puts "Starting Sidekiq..."
    system "bundle exec sidekiq -e#{Rails.env} -C config/sidekiq.yml -P #{sidekiq_pid_file} -d -L #{sidekiq_log_file}" # starts sidekiq process here
    sleep(2)
    puts "Sidekiq started #PID-#{File.readlines(sidekiq_pid_file).first}."
  end

  desc "Sidekiq restart"
  task :restart do
    puts "#### Trying to restart Sidekiq Now !!! ####"
    Rake::Task['sidekiq:stop'].invoke
    Rake::Task['sidekiq:start'].invoke
    puts "#### Sidekiq restarted successfully !!! ####"
  end
end
