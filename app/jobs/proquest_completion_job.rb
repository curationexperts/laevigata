# Record the successful completion of an ETD submission to ProQuest.
# Called by ProquestJob.
class ProquestCompletionJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  # @param [String] work_id - the id of the work object
  def perform(work_id)
    @work = Etd.find(work_id)
    # Record the transmission on the object
    @work.proquest_submission_date = [Time.zone.today]
    @work.save
  end
end
