require 'workflow_setup'

module Hyrax
  module Workflow
    # Notification to ProQuest and application admins summarizing ProQuest uploads.
    class ProquestNotification
      def self.send_notification(subject, message)
        ProquestNotification.new(subject, message).call
      end

      def initialize(subject, message)
        @subject = subject
        @message = message
      end

      def call
        Rails.logger.warn "ProquestNotification sent to #{ENV['PROQUEST_NOTIFICATION_EMAIL']}: #{@message}"
        user = ::User.find_or_create_by(uid: WorkflowSetup::NOTIFICATION_OWNER)
        recipients.each do |recipient|
          user.send_message(recipient, @message, @subject)
        end
      end

      # Send this to the application admins + proquest submission service
      def recipients
        admin_role = Role.find_by(name: "admin")
        admin_role.users.to_a << proquest_user
      end

      def proquest_user
        pu = ::User.find_or_create_system_user("proquest_user")
        pu.display_name = "ProQuest ETD Submission Service"
        pu.email = ENV['PROQUEST_NOTIFICATION_EMAIL']
        pu.save
        pu
      end
    end
  end
end
