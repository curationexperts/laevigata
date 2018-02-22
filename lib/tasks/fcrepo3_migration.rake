namespace :emory do
  desc 'Migrate ETDs from FCRepo3; provide a file of line separated pids'
  task :migrate_etds, [:pid_file] => [:environment] do |_task, args|
    Rails.application.config.active_job.queue_adapter = :sidekiq # ensure sidekiq
    parser = Importer::LaevigataImporter.new(file: File.open(args[:pid_file]))

    parser.source_host = ENV['FCREPO3_MIGRATION_HOST'] ||
                         'http://repo.library.emory.edu/fedora/objects/'

    record_importer = Importer::AsynchronousRecordImporter.new

    Darlingtonia::Importer
      .new(parser: parser, record_importer: record_importer)
      .import
  end
end
