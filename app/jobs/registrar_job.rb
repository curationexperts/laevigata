class RegistrarJob < ApplicationJob
  queue_as :default

  after_enqueue do |job|
    registrar_feed = job.arguments.first
    registrar_feed.queued!
  end

  def perform(registrar_feed)
    registrar_feed.processing!

    registrar_data_path = ActiveStorage::Blob.service.path_for(registrar_feed.graduation_records.key)
    grad_service = GraduationService.run(registrar_data_path)
    registrar_feed.report.attach(io: File.open(grad_service.graduation_report.filename),
                                 filename: grad_service.graduation_report.filename.basename,
                                 content_type: 'text/csv')
    registrar_feed.completed!
  rescue
    registrar_feed.errored!
  end
end
