require 'workflow_setup'
require 'net/sftp'

# Submit an ETD to ProQuest.
# Called by GraduationJob.
# This job will re-try until the submission has been completed.
# If SFTP `transmit` is true, then the job will retry until ProQuest
# accepts the SFTP package.
class ProquestJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  # @param [String] work_id - the id of the ETD
  # @param [Hash] grad_record - a hash containing registrar data matched to the ETD
  # @param [Boolean] transmit - true: send package to ProQuest, false: only create zipfile, don't send
  # @param [Boolean] cleanup - true: erase the zipfile after the job, false: leave the file on disk
  # @param [Boolean] retransmit - true: recreate the submission file even it has already been sent
  def perform(work_id, grad_record = {}, transmit: true, cleanup: true, retransmit: false)
    work = Etd.find(work_id)
    return unless work.submit_to_proquest?(retransmit)
    Rails.logger.info "ETD #{work_id} beginning submission to ProQuest"
    # 1. Create a directory. Done. See config/environments
    # 2. Write XML file there Done.
    # 3. Write PDF and supplementary files there. Done.
    # 4. Zip the directory. Done. Tasks 1 - 4 encapsulated in export_zipped_proquest_package
    upload_file = work.export_zipped_proquest_package(grad_record)
    # 5. Transmit the zip to ProQuest
    transmit_file(upload_file, work.upload_file_id) if transmit
    cleanup_file(upload_file) if cleanup
    work.proquest_submission_date = [Date.current]
    work.save
    Rails.logger.info "ETD #{work_id} finished submission to ProQuest"
  end

  # Transmit the exported file to ProQuest SFTP server
  def transmit_file(upload_file, file_id)
    Net::SFTP.start(ENV['PROQUEST_SFTP_HOST'], ENV['PROQUEST_SFTP_USER'], password: ENV['PROQUEST_SFTP_PASSWORD']) do |sftp|
      Rails.logger.debug "Uploading #{upload_file} to ProQuest"
      sftp.upload!(upload_file, "#{file_id}.zip")
    end
  end

  # Delete the transmitted file
  def cleanup_file(upload_file)
    File.delete(upload_file)
  end
end
