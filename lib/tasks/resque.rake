require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'

  Resque.after_fork do
    ActiveRecord::Base.establish_connection
  end
end
