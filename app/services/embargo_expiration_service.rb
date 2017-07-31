# An automated service that:
# 1. Checks the repository for works that will expire in 60 days, 7 days, or today
# 2. If a work expires in 60 days or 7 days, send the appropriate notification
# 3. If the work expires today, send the appropriate notification and remove the embargo
# 4. Send a summary report to the application admins
# @example How to call this service
#  # Run today's notifications
#  EmbargoExpirationService.run
#  # Run yesterday's notifications
#  EmbargoExpirationService.run(Time.zone.today - 1.day)
class EmbargoExpirationService
  attr_reader :summary_report, :summary_report_subject
  # Run the service. By default, it will check expirations against today.
  # You can also pass in a date.
  # @param [Date] date the date by which to measure expirations
  def self.run(date = Time.zone.today)
    date = Date.parse(date)
    Rails.logger.info "Running embargo expiration service for #{date}"
    EmbargoExpirationService.new(date).run
  end

  # Format a Date object such that it can be used in a solr query
  # @param [Date] date
  # @return [String] date formatted like "2017-07-27T00:00:00Z"
  def solrize_date(date)
    date.strftime('%Y-%m-%dT00:00:00Z')
  end

  def initialize(date)
    @date = date
    @summary_report = "Summary embargo report for #{date}\n"
    @summary_report_subject = "ETD embargos summary: #{date}"
  end

  # Given a work, format it for inclusion in the summary report
  def format_for_summary_report(work)
    "\n#{work.creator.first}. #{work.title.first} (#{document_path(work)})"
  end

  def document_path(document)
    key = document.model_name.singular_route_key
    Rails.application.routes.url_helpers.send(key + "_path", document.id)
  end

  def run
    send_today_notifications
    send_seven_day_notifications
    send_sixty_day_notifications
    expire_embargoes
    send_summary_report
  end

  def send_sixty_day_notifications
    @summary_report << "\n\nETD embargoes expiring in 60 days\n"
    expirations = find_expirations(60)
    expirations.each do |expiration|
      work_global_id = expiration.to_global_id.to_s
      entity = Sipity::Entity.where(proxy_for_global_id: work_global_id).first
      user = ::User.where(ppid: expiration.depositor).first
      recipients = { 'to' => [user] }
      Hyrax::Workflow::SixtyDayEmbargoNotification.send_notification(
        entity: entity,
        comment: '',
        user: user,
        recipients: recipients
      )
      @summary_report << format_for_summary_report(expiration)
    end
  end

  def send_seven_day_notifications
    @summary_report << "\n\nETD embargoes expiring in 7 days\n"
    expirations = find_expirations(7)
    expirations.each do |expiration|
      work_global_id = expiration.to_global_id.to_s
      entity = Sipity::Entity.where(proxy_for_global_id: work_global_id).first
      user = ::User.where(ppid: expiration.depositor).first
      recipients = { 'to' => [user] }
      Hyrax::Workflow::SevenDayEmbargoNotification.send_notification(
        entity: entity,
        comment: '',
        user: user,
        recipients: recipients
      )
      @summary_report << format_for_summary_report(expiration)
    end
  end

  def send_today_notifications
    @summary_report << "\n\nETD embargoes expiring today (#{@date})\n"
    expirations = find_expirations(0)
    expirations.each do |expiration|
      work_global_id = expiration.to_global_id.to_s
      entity = Sipity::Entity.where(proxy_for_global_id: work_global_id).first
      user = ::User.where(ppid: expiration.depositor).first
      recipients = { 'to' => [user] }
      Hyrax::Workflow::TodayEmbargoNotification.send_notification(
        entity: entity,
        comment: '',
        user: user,
        recipients: recipients
      )
      @summary_report << format_for_summary_report(expiration)
    end
  end

  def send_summary_report
    Hyrax::Workflow::EmbargoSummaryReportNotification.send_notification(@summary_report_subject, @summary_report)
  end

  def expire_embargoes
    expirations = find_expirations(0)
    expirations.each do |expiration|
      expiration.deactivate_embargo!
      expiration.embargo.save
      expiration.save
    end
  end

  # Find all ETDs what will expire in the given number of days
  # @param [Integer] number of days
  def find_expirations(days)
    expiration_date = solrize_date(@date + days.send(:days))
    Etd.where("embargo_release_date_dtsi:#{RSolr.solr_escape(expiration_date)}")
  end
end
