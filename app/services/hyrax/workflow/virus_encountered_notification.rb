module Hyrax
  module Workflow
    # Notify depositing user, plus approvers, that a virus was encountered
    # and the file was deleted.
    class VirusEncounteredNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      private

        def subject
          "Virus encountered in #{title}"
        end

        def message
          "A virus has been detected in the work #{title} (#{link_to work_id, document_path}). " \
          "The infected file has been deleted and a clean version will need to be resubmitted."
        end
    end
  end
end
