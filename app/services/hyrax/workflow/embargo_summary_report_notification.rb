require 'workflow_setup'

module Hyrax
  module Workflow
    # Notification that embargo will expire sixty days from today.
    # Should notify work depositor only
    class EmbargoSummaryReportNotification
      def self.send_notification(subject, message)
        EmbargoSummaryReportNotification.new(subject, message).call
      end

      def initialize(subject, message)
        @subject = subject
        @message = message
      end

      def call
        Rails.logger.warn "EmbargoSummaryReportNotification sent: #{@message}"
        user = ::User.find_or_create_by(uid: WorkflowSetup::NOTIFICATION_OWNER)
        recipients.each do |recipient|
          Rails.logger.warn "EmbargoSummaryReportNotification sent to #{recipient.email}"
          user.send_message(recipient, @message, @subject)
        end
      end

      # Only send this to the application admins
      def recipients
        admin_role = Role.find_by(name: "admin")
        admin_role.users.to_a
      end
    end
  end
end
