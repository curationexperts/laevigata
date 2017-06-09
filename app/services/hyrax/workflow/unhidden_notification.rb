module Hyrax
  module Workflow
    class UnhiddenNotification < AbstractNotification
      private

        def subject
          'Deposit has been unhidden'
        end

        def message
          "#{title} (#{link_to work_id, document_path}) was unhidden by #{user.user_key}  #{comment}"
        end

        def users_to_notify
          super << user
        end
    end
  end
end
