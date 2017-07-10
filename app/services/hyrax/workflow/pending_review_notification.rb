module Hyrax
  module Workflow
    class PendingReviewNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (reviewers << depositor) }
      end

      private

        def subject
          'Deposit needs review'
        end

        def message
          "#{title} (#{link_to work_id, document_path}) was deposited by #{user.display_name} and is awaiting initial review. #{comment}"
        end
    end
  end
end
