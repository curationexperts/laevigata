module Hyrax
  module Workflow
    class PendingApprovalNotification < AbstractNotification
      protected

        def subject
          "Deposit #{title} is awaiting approval"
        end

        def message
          "#{title} (#{link_to work_id, document_path}) was deposited by #{user.display_name} and is awaiting approval. #{comment}"
        end

      private

        def users_to_notify
          super << user
        end
    end
  end
end
