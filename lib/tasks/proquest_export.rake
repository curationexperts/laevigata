namespace :emory do
  desc "Export and optionally send a specific ProQuest package"
  task :proquest_export, [:id] => [:environment] do |_t, args|
    puts "Running ProquestJob for id #{args[:id]}"
    ProquestJob.perform_now(args[:id], transmit: false, cleanup: false, retransmit: true)
  end
end
