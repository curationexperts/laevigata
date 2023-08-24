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
  def self.run(date = nil)
    rundate =
      if date
        Date.parse(date)
      else
        Time.zone.today
      end
    Rails.logger.warn "EmbargoExpirationService: Running embargo expiration service for #{rundate}"
    EmbargoExpirationService.new(rundate).run
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
      Hyrax::Workflow::SixtyDayEmbargoNotification.send_notification(expiration.id)
      @summary_report << format_for_summary_report(expiration)
    end
  end

  def send_seven_day_notifications
    @summary_report << "\n\nETD embargoes expiring in 7 days\n"
    expirations = find_expirations(7)
    expirations.each do |expiration|
      Hyrax::Workflow::SevenDayEmbargoNotification.send_notification(expiration.id)
      @summary_report << format_for_summary_report(expiration)
    end
  end

  def send_today_notifications
    @summary_report << "\n\nETD embargoes expiring today (#{@date})\n"
    expirations = find_expirations(0)
    expirations.each do |expiration|
      Hyrax::Workflow::TodayEmbargoNotification.send_notification(expiration.id)
      @summary_report << format_for_summary_report(expiration)
    end
  end

  def send_summary_report
    Hyrax::Workflow::EmbargoSummaryReportNotification.send_notification(@summary_report_subject, @summary_report)
  end

  def expire_embargoes
    expirations = find_expirations(0)
    expirations.each do |expiration|
      Rails.logger.warn "ETD #{expiration.id}: Expiring embargo"
      expiration.visibility = expiration.visibility_after_embargo if expiration.visibility_after_embargo
      expiration.deactivate_embargo!
      expiration.embargo.save
      expiration.save
      expiration.file_sets.each do |fs|
        fs.visibility = expiration.visibility
        fs.deactivate_embargo!
        fs.save
      end
    end
  end

  # Find all ETDs what will expire in the given number of days
  # @param [Integer] number of days
  def find_expirations(days)
    expiration_date = solrize_date(@date + days.send(:days))
    Etd.where("embargo_release_date_dtsi:#{expiration_date}")
  end

  # Format a Date object to serarch for any time during that day
  # Returns Solr range query format: [x TO y} which includes the start of the range, but excludes the end of the range
  # @param [Date] date
  # @return [String] date formatted like "[2017-07-27T00:00:00Z TO 2017-07-28T0:00:00Z}"
  def solrize_date(date)
    start = date.strftime('%Y-%m-%dT00:00:00Z')
    finish = (date + 1.day).strftime('%Y-%m-%dT00:00:00Z')
    "[#{start} TO #{finish}}"
  end
end
