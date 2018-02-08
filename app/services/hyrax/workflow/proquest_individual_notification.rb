require 'workflow_setup'

module Hyrax
  module Workflow
    # Notification to an individual that their ETD has been submitted to ProQuest.
    # Should notify work depositor only.
    class ProquestIndividualNotification
      def self.send_notification(work_id, subject, message)
        ProquestIndividualNotification.new(work_id, subject, message).call
      end

      def initialize(work_id, subject, message)
        @work = Etd.find(work_id)
        @subject = subject
        @message = message
      end

      def call
        user = ::User.find_or_create_by(uid: WorkflowSetup::NOTIFICATION_OWNER)
        recipients.each do |recipient|
          user.send_message(recipient, @message, @subject)
        end
      end

      # Send this to the depositor only
      def recipients
        Array.wrap(::User.find_by_user_key(@work.depositor))
      end
    end
  end
end
