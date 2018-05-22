# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToWorkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
  def perform(work, uploaded_files, **work_attributes)
    validate_files!(uploaded_files)
    depositor = proxy_or_depositor(work)
    user = User.find_by_user_key(depositor)
    work_permissions = work.permissions.map(&:to_hash)
    metadata = visibility_attributes(work_attributes)
    uploaded_files.each do |uploaded_file|
      virus_check!(uploaded_file)
      actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
      actor.create_metadata(metadata)
      actor.create_content(uploaded_file)
      actor.file_set.pcdm_use = uploaded_file.pcdm_use
      if uploaded_file.pcdm_use == 'primary'
        actor.file_set.title = work.title
      else
        actor.file_set.title = Array.wrap(uploaded_file.title || uploaded_file.file.file.filename)
        actor.file_set.description = Array.wrap(uploaded_file.description)
        actor.file_set.file_type   = uploaded_file.file_type
      end
      actor.attach_to_work(work)
      actor.file_set.permissions_attributes = work_permissions
      uploaded_file.update(file_set_uri: actor.file_set.uri)
    end
  rescue VirusDetectedError
    Rails.logger.error "Virus encountered while processing work #{work.id}."

    work_global_id = work.to_global_id.to_s
    entity         = Sipity::Entity.find_by(proxy_for_global_id: work_global_id)

    Hyrax::Workflow::VirusEncounteredNotification
      .send_notification(entity:     entity,
                         comment:    '',
                         user:       ::User.find_by(ppid: WorkflowSetup::NOTIFICATION_OWNER))
  end

  class VirusDetectedError < RuntimeError; end

  private

    def virus_check!(uploaded_file)
      return unless Hydra::Works::VirusCheckerService.file_has_virus?(uploaded_file.file)
      carrierwave_file = uploaded_file.file.file
      carrierwave_file.delete
      raise(VirusDetectedError, carrierwave_file.filename)
    end

    # The attributes used for visibility - sent as initial params to created FileSets.
    def visibility_attributes(attributes)
      attributes.slice(:visibility, :visibility_during_lease,
                       :visibility_after_lease, :lease_expiration_date,
                       :embargo_release_date, :visibility_during_embargo,
                       :visibility_after_embargo)
    end

    def validate_files!(uploaded_files)
      uploaded_files.each do |uploaded_file|
        next if uploaded_file.is_a? Hyrax::UploadedFile
        raise ArgumentError, "Hyrax::UploadedFile required, but #{uploaded_file.class} received: #{uploaded_file.inspect}"
      end
    end

    ##
    # A work with files attached by a proxy user will set the depositor as the intended user
    # that the proxy was depositing on behalf of. See tickets #2764, #2902.
    def proxy_or_depositor(work)
      work.on_behalf_of.blank? ? work.depositor : work.on_behalf_of
    end
end
