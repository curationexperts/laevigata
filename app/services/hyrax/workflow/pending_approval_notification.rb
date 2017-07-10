module Hyrax
  module Workflow
    class PendingApprovalNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      private

        def subject
          "Deposit #{title} is awaiting approval"
        end

        def message
          "#{title} (#{link_to work_id, document_path}) was deposited by #{user.display_name} and is awaiting approval. #{comment}"
        end
    end
  end
end
