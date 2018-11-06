module Hyrax
  module Workflow
    class CommentNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      def subject
        "Comment on Deposit"
      end

      def message
        "#{user.display_name} has added a comment to #{title} (#{link_to work_id, document_url}) deposited by #{depositor.display_name}: \n\n #{comment}"
      end
    end
  end
end
