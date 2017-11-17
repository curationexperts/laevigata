module Hyrax
  module Workflow
    # Notification of state change to "degree_awarded".
    # Should notify users with the approving role for the work's AdminSet, plus super users, plus the depositor
    class DegreeAwardedNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      def subject
        "Degree awarded for #{title}"
      end

      def message
        "The degree associated with #{title} (#{link_to work_id, document_url}) has been awarded."
      end
    end
  end
end
