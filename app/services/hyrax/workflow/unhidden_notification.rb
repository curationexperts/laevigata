module Hyrax
  module Workflow
    class UnhiddenNotification < AbstractNotification
      private

        def subject
          'Deposit has been unhidden'
        end

        def message
          "#{title} (#{link_to work_id, document_path}) was unhidden by #{user.display_name}  #{comment}"
        end

        def users_to_notify
          super << user
        end
    end
  end
end
