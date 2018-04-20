namespace :emory do
  namespace :read_only do
    desc "Put the system in read-only mode to enable consistent backups"
    task :on do
      message = "Going into read-only mode to enable backups."
      Rails.logger.warn message
      puts message
      read_only_feature = Hyrax::Feature.find_by_key("read_only")
      read_only_feature.enabled = true
      read_only_feature.save
      Rake::Task['sidekiq:stop'].invoke
      puts "Read only mode: #{Flipflop.read_only?}"
    end

    desc "Turn off read-only mode: restore normal operations."
    task :off do
      message = "Restoring normal operations -- turning off read only mode."
      Rails.logger.warn message
      puts message
      read_only_feature = Hyrax::Feature.find_by_key("read_only")
      read_only_feature.enabled = false
      read_only_feature.save
      Rake::Task['sidekiq:start'].invoke
      puts "Read only mode: #{Flipflop.read_only?}"
    end
  end
end
