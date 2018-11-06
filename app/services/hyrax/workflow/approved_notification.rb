module Hyrax
  module Workflow
    # Notification of state change to "approved".
    # Should notify users with the approving role for the work's AdminSet, plus super users.
    class ApprovedNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      def subject
        "Deposit #{title} has been approved"
      end

      def message
        "The work titled \"#{title}\" deposited by #{depositor.display_name} has been approved by #{user.display_name}.

        Comments (if any):
         #{comment}

         You can view the work in the Emory Electronic Thesis and Dissertation system at
         #{link_to document_url, document_url}
      "
      end
    end
  end
end
