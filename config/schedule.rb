# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Daily, check whether we sent anything to ProQuest and deliver
# notifications if so
every :day, at: '11:55pm' do
  rake "emory:proquest_notifications"
end

every :day, at: '2:20am' do
  rake "emory:embargo_expiration"
end

# Delete blacklight saved searches
every :day, at: '11:55pm' do
  rake "blacklight:delete_old_searches[1]"
end

# Remove files in /tmp owned by the deploy user that are older than 7 days
every :day, at: '1:00am' do
  command "/usr/bin/find /tmp -type f -mtime +7 -user deploy -execdir /bin/rm -- {} \\;"
end
