namespace :emory do
  desc "Send notifications about proquest submissions -- Pass date YYYY-MM-DD -- Defaults to today."
  task :proquest_notifications, [:date] => [:environment] do |_t, args|
    puts "Running ProquestNotificationService"
    ProquestNotificationService.run(args[:date])
  end
end
