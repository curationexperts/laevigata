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
    Rails.logger.info "Work #{work_id} graduation recorded as #{graduation_date}"
    @work = Etd.find(work_id)
    record_degree_awarded_date(graduation_date)
    update_embargo_release_date
    activate_object
    ProquestJob.perform_later(@work.id)
    send_notifications
    @work.save
  end

  # Given a graduation date and an embargo length, calculate the embargo_release_date.
  # This assumes embargo_length values like "6 months", "2 months", "6 years"
  def self.embargo_length_to_embargo_release_date(graduation_date, embargo_length)
    number, units = embargo_length.split(" ")
    graduation_date = Date.parse(graduation_date) if graduation_date.class == String
    graduation_date + Integer(number).send(units.to_sym)
  end

  protected

    # TODO: Check for formatting and whether we need String to Date conversion
    # @param [Date] graduation_date
    def record_degree_awarded_date(graduation_date)
      @work.degree_awarded = graduation_date
    end

    def update_embargo_release_date
      return unless @work.embargo_length
      @work.embargo.embargo_release_date = GraduationJob.embargo_length_to_embargo_release_date(@work.degree_awarded, @work.embargo_length)
      @work.embargo.save
      Rails.logger.info "Work #{@work.id} embargo release date set to #{@work.embargo.embargo_release_date}"
    end

    def send_notifications
      work_global_id = @work.to_global_id.to_s
      entity = Sipity::Entity.where(proxy_for_global_id: work_global_id).first
      Hyrax::Workflow::DegreeAwardedNotification.send_notification(entity: entity, comment: '', user: ::User.where(ppid: WorkflowSetup::NOTIFICATION_OWNER).first, recipients: nil)
    end

    # Replicating behavior of Hyrax::Workflow::ActivateObject
    def activate_object
      @work.state = Vocab::FedoraResourceStatus.active
    end
end
