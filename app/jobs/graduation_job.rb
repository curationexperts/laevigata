# Everything that needs to happen when a student graduates.
# To be called by an automated process that queries the registrar data.
class GraduationJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  def perform(work)
    @work = work
    record_degree_awarded_date
    update_embargo_release_date
    @work.save
  end

  # Given a graduation date and an embargo length, calculate the embargo_release_date.
  # This assumes embargo_length values like "6 months", "2 months", "6 years"
  def self.embargo_length_to_embargo_release_date(graduation_date, embargo_length)
    number, units = embargo_length.split(" ")
    graduation_date + Integer(number).send(units.to_sym)
  end

  protected

    # TODO: Replace this with a real query to registrar data
    def record_degree_awarded_date
      @work.degree_awarded = Time.zone.today
    end

    def update_embargo_release_date
      @work.embargo.embargo_release_date = GraduationJob.embargo_length_to_embargo_release_date(@work.degree_awarded, @work.embargo_length)
      @work.embargo.save
    end
end
