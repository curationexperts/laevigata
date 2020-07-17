require 'workflow_setup'

# Everything that needs to happen when a student graduates.
# To be called by an automated process that queries the registrar data.
# When a student graduates, this job should:
# 1. record the student's graduation date
# 2. update the embargo relese date, if applicable
# 3. submit work to proquest, if applicable
# 4. send notifications to approvers, faculty advisors, and depositor
class GraduationJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  # @param [String] work_id - the id of the work object
  # @param [Date] the student's graduation date
  def perform(work_id, graduation_date = Time.zone.today.to_s)
    Rails.logger.warn "Graduation Job: ETD #{work_id} graduation recorded as #{graduation_date}"
    @work = Etd.find(work_id)
    record_degree_awarded_date(graduation_date)
    update_embargo_release_date
    update_depositor_email
    publish_object
    ProquestJob.perform_later(@work.id)
    send_notifications
    @work.save
  end

  # @param [Date] graduation_date
  def record_degree_awarded_date(graduation_date)
    @work.degree_awarded = graduation_date
  end

  class UserNotFoundError < RuntimeError; end

  # Update the email address of the depositor with their post-graduation email,
  # so that we use that for all future notifications
  def update_depositor_email
    depositor = ::User.find_by_user_key(@work.depositor)
    raise UserNotFoundError if depositor.nil?
    depositor.email = @work.post_graduation_email.first
    depositor.save
  rescue UserNotFoundError
    Honeybadger.notify("ETD #{@work.id}: Could not update post-graduation email address because could not find user with id #{@work.depositor}")
    Rails.logger.error "ETD #{@work.id}: Could not update post-graduation email address because could not find user with id #{@work.depositor}"
  end

  def update_embargo_release_date
    return unless @work.embargo_length
    embargo_release_date = GraduationHelper.embargo_length_to_embargo_release_date(@work.degree_awarded, @work.embargo_length)
    @work.embargo.embargo_release_date = embargo_release_date
    @work.embargo.save
    @work.file_sets.each do |fs|
      if fs.embargo.nil?
        fs.apply_embargo(
          embargo_release_date,
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE,
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        )
      end
      fs.embargo.embargo_release_date = embargo_release_date
      fs.embargo.save
    end
    Rails.logger.warn "Graduation Job: ETD #{@work.id} embargo release date set to #{@work.embargo.embargo_release_date}"
  rescue => e
    Rails.logger.error "Error updating embargo release date for work #{@work}: #{e}"
    Honeybadger.notify("Error updating embargo release date for work #{@work}: #{e}")
  end

  def send_notifications
    work_global_id = @work.to_global_id.to_s
    entity = Sipity::Entity.where(proxy_for_global_id: work_global_id).first
    Hyrax::Workflow::DegreeAwardedNotification.send_notification(entity: entity, comment: '', user: ::User.where(ppid: WorkflowSetup::NOTIFICATION_OWNER).first)
  end

  # Transition the workflow of this object to the "published" workflow state
  # This should also mark it as active.
  def publish_object
    Rails.logger.warn "Graduation Job: Publishing ETD #{@work.id}"
    approving_user = ::User.find_by_uid(WorkflowSetup::ADMIN_SET_OWNER)
    subject = Hyrax::WorkflowActionInfo.new(@work, approving_user)
    sipity_workflow_action = PowerConverter.convert_to_sipity_action("publish", scope: subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Published by graduation job #{Time.zone.today}")
  end
end
