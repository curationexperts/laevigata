module Hyrax
  module Workflow
    # Notification of state change to "changes_required".
    # Should notify work depositor, users with the approving role for the work's AdminSet, plus super users.
    class ChangesRequiredNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      def subject
        "Deposit #{title} requires changes"
      end

      def message
        "#{title} (#{link_to work_id, document_url}) requires additional changes before approval.\n\n '#{comment}'"
      end
    end
  end
end
