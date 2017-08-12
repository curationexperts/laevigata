module Hyrax
  module Workflow
    # Notification of state change to "approved".
    # Should notify users with the approving role for the work's AdminSet, plus super users.
    class VirusEncounteredNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      private

        def subject
          "Virus encountered processing #{title}"
        end

        def message
          "A virus has been detected in the work #{title} (#{link_to work_id, document_path}). " \
          "The infected file has been deleted and a clean version will need to be resubmitted."
        end
    end
  end
end
