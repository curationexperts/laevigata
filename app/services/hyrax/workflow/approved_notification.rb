module Hyrax
  module Workflow
    # Notification of state change to "approved".
    # Should notify users with the approving role for the work's AdminSet, plus super users.
    class ApprovedNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      private

        def subject
          "Deposit #{title} has been approved"
        end

        def message
          "#{title} (#{link_to work_id, document_path}) has been approved by #{user.display_name}  #{comment}"
        end
    end
  end
end
