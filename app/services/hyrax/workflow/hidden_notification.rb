module Hyrax
  module Workflow
    class HiddenNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      def subject
        'Deposit has been hidden'
      end

      def message
        "#{title} (#{link_to work_id, document_url}) was hidden by #{user.display_name}  #{comment}"
      end

      def users_to_notify
        super << user
      end
    end
  end
end
