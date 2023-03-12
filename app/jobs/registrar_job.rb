class RegistrarJob < ApplicationJob
  queue_as :default

  after_enqueue do |job|
    registrar_feed = job.arguments.first
    registrar_feed.queued!
  end

  def perform(registrar_feed)
    registrar_feed.processing!

    GraduationService.run(registrar_feed)

    registrar_feed.completed!
  rescue => error
    attach_error_to(registrar_feed, error)
    registrar_feed.errored!
  end

  private

  def attach_error_to(registrar_feed, error)
    registrar_feed.report.attach(
      io: StringIO.open("#{error.class}: #{error.message}"),
      filename: 'error.txt',
      content_type: 'text/plain'
    )
  end
end
