require 'workflow_setup'

module Hyrax
  module Workflow
    # Notification to a depositor that a file they attempted to attach from Box
    # could not be retrieved.
    # Should notify work depositor only.
    class BoxErrorNotification
      def self.send_notification(work_id)
        BoxErrorNotification.new(work_id).call
      end

      def initialize(work_id)
        @work = Etd.find(work_id)
        @message = message
        @subject = subject
      end

      def message
        "Your ETD submission #{@work.title.first} has encountered an error during processing.

        You recently attempted to attach a file from box.com to an ETD submission
        at https://etd.library.emory.edu/concern/etds/#{@work.id}. Unfortunately, attempting to retrieve that
        file from box.com resulted in an error. Please return to your ETD submission
        and re-submit the file.

        When you submit a file from Box.com, please leave the file in place on Box until
        your ETD submission has been approved.
        "
      end

      def subject
        "Failed to attach file to #{@work.title.first}"
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
