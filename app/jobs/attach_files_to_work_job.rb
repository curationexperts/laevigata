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
  end

  private

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

# Converts UploadedFiles into FileSets and attaches them to works.
# class AttachFilesToWorkJob < ActiveJob::Base
#   queue_as Hyrax.config.ingest_queue_name

#   # @param [ActiveFedora::Base] work - the work object
#   # @param [Array<UploadedFile>] uploaded_files - an array of files to attach
#   def perform(work, uploaded_files)
#     uploaded_files.each do |uploaded_file|
#       file_set = FileSet.new
#       user = User.find_by_user_key(work.depositor)
#       actor = Hyrax::Actors::FileSetActor.new(file_set, user)
#       actor.create_metadata(visibility: work.visibility)
#       attach_content(actor, uploaded_file.file)
#       actor.attach_file_to_work(work)
#       actor.file_set.permissions_attributes = work.permissions.map(&:to_hash)
#       file_set.pcdm_use = uploaded_file.pcdm_use
#       if uploaded_file.pcdm_use == 'primary'
#         file_set.title = work.title
#       else
#         file_set.title = Array.wrap(uploaded_file.title)
#         file_set.description = Array.wrap(uploaded_file.description)
#         file_set.file_type = uploaded_file.file_type
#       end
#       file_set.save
#       uploaded_file.update(file_set_uri: file_set.uri)
#     end.
#   rescue ActiveFedora::RecordInvalid => e
#     # If the file set cannot be saved because a virus was encountered,
#     # delete the file and notify the depositor and approvers
#     raise e unless e.to_s =~ /virus/
#     Rails.logger.error "Virus encountered while processing work #{work.id}."
#     work_global_id = work.to_global_id.to_s
#     entity = Sipity::Entity.where(proxy_for_global_id: work_global_id).first
#     Hyrax::Workflow::VirusEncounteredNotification.send_notification(entity: entity, comment: '', user: ::User.where(ppid: WorkflowSetup::NOTIFICATION_OWNER).first, recipients: nil)
#   end

#   private

#     # @param [Hyrax::Actors::FileSetActor] actor
#     # @param [Hyrax::UploadedFileUploader] file file.file must be a CarrierWave::SanitizedFile or file.url must be present
#     def attach_content(actor, file)
#       if file.file.is_a? CarrierWave::SanitizedFile
#         actor.create_content(file.file.to_file)
#       elsif file.url.present?
#         actor.import_url(file.url)
#       else
#         raise ArgumentError, "#{file.class} received with #{file.file.class} object and no URL"
#       end
#     end
# end
