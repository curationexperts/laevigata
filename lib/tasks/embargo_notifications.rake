namespace :emory do
  desc "Remove expired embargoes and send notifications. Pass date YYYY-MM-DD. Defaults to today."
  task :embargo_expiration, [:date] => [:environment] do |_t, args|
    EmbargoExpirationService.run(args[:date])
  end
end
