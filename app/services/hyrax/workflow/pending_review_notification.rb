module Hyrax
  module Workflow
    class PendingReviewNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (reviewers << depositor) }
      end

      def subject
        'Deposit needs review'
      end

      def message
        "#{title} (#{link_to work_id, document_url}) was updated by #{user.display_name} and is awaiting review & approval. #{comment}"
      end
    end
  end
end
