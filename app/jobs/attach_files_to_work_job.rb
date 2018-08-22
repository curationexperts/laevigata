# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToWorkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
  def perform(work, uploaded_files, **work_attributes)
    validate_files!(uploaded_files)
    depositor = proxy_or_depositor(work)
    user = User.find_by_user_key(depositor)
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
      actor.attach_to_work(work, metadata)
      uploaded_file.update(file_set_uri: actor.file_set.uri)
    end
    # If the Depositor already has edit rights, make sure those get applied to
    # any newly added files. These methods get called correctly when a work is
    # first returned to a depositor for changes, but they do not otherwise get called for
    # subsequent file changes. This fixes a bug where a user can only replace their
    # files once.
    if in_edit_state?(work)
      Hyrax::Workflow::GrantEditToDepositor.call(target: work.reload)
      InheritPermissionsJob.perform_now(work)
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

    # Does the work already have a workflow assigned? And if so,
    # is it already in a state where the depositor can edit it?
    # If both of those are true, then we want to ensure the
    # depositor can also edit all attached filesets.
    def in_edit_state?(work)
      return false unless work && work.to_sipity_entity
      Hyrax::Workflow::PermissionQuery
        .scope_permitted_workflow_actions_available_for_current_state(
          user: User.find_by_user_key(work.depositor),
          entity: work.to_sipity_entity
        ).pluck(:name).include?("request_review")
    end

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
