require 'workflow_setup'

# Submit an ETD to ProQuest.
# Called by GraduationJob.
class ProquestJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  def perform(work)
    @work = work
    return unless ProquestJob.submit_to_proquest?(@work)
    @xml = @work.export_proquest_xml
    # TODO: submit to ProQuest
    # 1. Create a directory. Done. See config/environments
    # 2. Write XML file there Done.
    # 3. Write PDF and supplementary files there. Done.
    # 4. Zip the directory. Done. Tasks 1 - 4 encapsulated in export_zipped_proquest_package
    @work.export_zipped_proquest_package
    # 5. Transmit the zip to ProQuest
    # 6. Send ProQuest an email notifying them of the transmission
    # 7. Record the transmission on the object
    # 8. Send notifications
    @work.save
  end

  # Does this work meet the criteria required for ProQuest submission?
  # @param [ActiveFedora::Base] work - the work object
  # @return [Boolean]
  def self.submit_to_proquest?(work)
    # Condition 1: Is it from Laney Graduate School?
    return false unless work.school.first == "Laney Graduate School"
    # Condition 2: Has it been approved?
    return false unless work.to_sipity_entity.workflow_state_name == 'approved'
    # Condition 3: Has the degree been awarded?
    return false unless work.degree_awarded.instance_of?(Date)
    # Condition 4: Is this a PhD?
    return true if work.degree.first == "PhD"
    # Condition 5: TODO: Or is this a Master's student who has chosen to submit?
    # return true if work.choose_proquest_submission == true
    false
  end
end
