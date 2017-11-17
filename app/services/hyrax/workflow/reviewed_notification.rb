module Hyrax
  module Workflow
    class ReviewedNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (reviewers << depositor) }
      end

      def subject
        'Deposit reviewed and ready for final approval'
      end

      def message
        "#{title} (#{link_to work_id, document_url}) has completed initial review and is awaiting final approval. #{comment}"
      end
    end
  end
end
