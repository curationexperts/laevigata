module Hyrax
  module Workflow
    class UnhiddenNotification < LaevigataNotification
      def workflow_recipients
        { "to" => (approvers << depositor) }
      end

      private

        def subject
          'Deposit has been unhidden'
        end

        def message
          "#{title} (#{link_to work_id, document_path}) was unhidden by #{user.display_name}  #{comment}"
        end
    end
  end
end
