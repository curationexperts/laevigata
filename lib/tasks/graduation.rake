namespace :emory do
  desc "Check for new graduates."
  task :graduation do
    console_logger = Logger.new(STDOUT)
    console_logger.level = Logger::WARN
    Rails.logger.extend(ActiveSupport::Logger.broadcast(console_logger))
    GraduationService.run
  end
end
