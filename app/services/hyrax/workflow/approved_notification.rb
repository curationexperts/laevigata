module Hyrax
  module Workflow
    class ApprovedNotification < AbstractNotification
      private

        def subject
          "Deposit #{title} has been approved"
        end

        def message
          "#{title} (#{link_to work_id, document_path}) has been approved by #{user.display_name}  #{comment}"
        end

        def users_to_notify
          super << user
        end
    end
  end
end
