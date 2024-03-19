class ApplicationJob < ActiveJob::Base
  def perform_now
    SemanticLogger.tagged(job_class: self.class, job_id: job_id) { super }
  end
end
