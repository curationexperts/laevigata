module Hyrax
  module Workflow
    class PublishedNotification < AbstractNotification
      def subject
        'Deposit reviewed and published'
      end

      def message
        "#{title} (#{link_to work_id, document_url}) was published by #{user.display_name}  #{comment}"
      end

      def users_to_notify
        super << user
      end
    end
  end
end
