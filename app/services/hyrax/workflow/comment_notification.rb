module Hyrax
  module Workflow
    class CommentNotification < AbstractNotification
      private

        def subject
          'Comment on Deposit'
        end

        def message
          "#{user.display_name} has added a comment to #{title} (#{link_to work_id, document_path}) \n\n #{comment}"
        end

        def users_to_notify
          super << user
        end
    end
  end
end
