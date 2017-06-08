module Hyrax
  module Workflow
    class HiddenNotification < AbstractNotification
      private

        def subject
          'Deposit has been hidden'
        end

        def message
          "#{title} (#{link_to work_id, document_path}) was hidden by #{user.user_key}  #{comment}"
        end

        def users_to_notify
          super << user
        end
    end
  end
end
