namespace :derivatives do
  desc "Recreate derivatives for all Etds"
  task recreate_all_etds: :environment do
    count = 0
    Etd.all.each do |etd|
      recreate_derivatives(etd)
      count += 1
    end
    puts "Recreated derivatives for #{count} etd(s)"
  end

  desc "Recreate derivatives for specified work, e.g., rake derivatives:recreate_by_id['c821gj76b']"
  task :recreate_by_id, [:id] => :environment do |_task, args|
    work_id = args[:id]
    raise "ERROR: no work id specified, aborting" if work_id.nil?
    work = ActiveFedora::Base.find(work_id)
    raise "ERROR: work #{work_id} does not exist, aborting" if work.nil?
    recreate_derivatives(work)
    puts "Recreated derivatives for work id #{work.id}"
  end

  # helpers
  #
  def recreate_derivatives(work)
    puts "Recreating derivatives for work #{work.id}"
    work.file_sets.each do |fs|
      puts " processing file set #{fs.id}"
      asset_path = fs.original_file.uri.to_s
      asset_path = asset_path[asset_path.index(fs.id.to_s)..-1]
      CreateDerivativesJob.perform_later(fs, asset_path)
    end
  end
end
