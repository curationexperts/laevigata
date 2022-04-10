namespace :emory do
  desc "Check for new graduates."
  task :graduation do
    # Echo logging to the console so we can track progress
    console_logger = Logger.new(STDOUT)
    ActiveSupport::Logger.broadcast(console_logger)
    GraduationService.run
  end
end
