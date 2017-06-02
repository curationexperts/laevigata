module Hyrax
  module Workflow
    class PublishedNotification < AbstractNotification
      private

        def subject
          'Deposit reviewed and published'
        end

        def message
          "#{title} (#{link_to work_id, document_path}) was published by #{user.user_key}  #{comment}"
        end

        def users_to_notify
          super << user
        end
    end
  end
end
