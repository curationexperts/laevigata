module Hyrax
  module Workflow
    class ReviewedNotification < AbstractNotification
      private

        def subject
          'Deposit reviewed and ready for final approval'
        end

        def message
          "#{title} (#{link_to work_id, document_path}) has completed initial review and is awaiting final approval. #{comment}"
        end

        def users_to_notify
          super << user
        end
    end
  end
end
