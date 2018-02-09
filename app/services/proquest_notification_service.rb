# An automated service that:
# 1. Checks the repository for works that were sent to proquest today
# (or on the date specified)
# 2. Send a summary to proquest of what works we transferred to them
# 3. Send a summary to application owners of what works were sent to ProQuest
# 4. Send notifications to each ETD author that their work was sent to ProQuest
# NOTE: See config/schedule.rb for the schedule that runs this service
# @example How to call this service
#  # Process all requests for today's date
#  ProquestNotificationService.run
#  # Process all requests for 8 Feb 2018
#  EmbargoExpirationService.run(2018-02-08)
class ProquestNotificationService
  # Run the service. By default, it will process today.
  # You can also pass in a date in the form YYYY-MM-DD
  # @param [Date] date - the date by which to query for proquest transmission
  def self.run(date = nil)
    rundate =
      if date
        Date.parse(date)
      else
        Time.zone.today
      end
    Rails.logger.info "Running proquest notification service for #{rundate}"
    ProquestNotificationService.new(rundate).run
  end

  # Format a Date object such that it can be used in a solr query
  # @param [Date] date
  # @return [String] date formatted like "2017-07-27T00:00:00Z"
  def solrize_date(date)
    date.strftime('%Y-%m-%dT00:00:00Z')
  end

  def initialize(date)
    @date = date
  end

  # Given a work, format it for inclusion in the proquest email
  def format_for_proquest_email(work)
    "<br/>#{work.creator.first}  #{work.upload_file_id}.zip"
  end

  def document_path(document)
    key = document.model_name.singular_route_key
    Rails.application.routes.url_helpers.send(key + "_path", document.id)
  end

  def run
    send_proquest_notification
    send_user_notifications
  end

  def send_proquest_notification
    return unless notification_list.count > 0
    message = "<em>Emory ProQuest Submission for #{@date}</em><br/><br/>"
    notification_list.each do |etd|
      message << format_for_proquest_email(etd)
    end
    Hyrax::Workflow::ProquestNotification.send_notification("Emory ProQuest Submission for #{@date}", message)
  end

  def send_user_notifications
    return unless notification_list.count > 0
    notification_list.each do |etd|
      subject = "Your work has been submitted to ProQuest"
      message = "Your work, #{etd.title.first}, has been submitted to ProQuest."
      Hyrax::Workflow::ProquestIndividualNotification.send_notification(etd.id, subject, message)
    end
  end

  # Find all ETDs sent to proquest on the given day
  def notification_list
    query_date = solrize_date(@date)
    Etd.where("proquest_submission_date_dtsim:#{RSolr.solr_escape(query_date)}")
  end
end
