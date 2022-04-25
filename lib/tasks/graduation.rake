namespace :emory do
  desc "Check for new graduates."
  task :graduation do
    console_logger = Logger.new(STDOUT).tagged('GraduationService')
    console_logger.level = Logger::INFO
    Rails.logger.extend(ActiveSupport::Logger.broadcast(console_logger))
    GraduationService.run
  end
end
