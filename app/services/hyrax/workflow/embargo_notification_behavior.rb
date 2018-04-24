module Hyrax
  module Workflow
    module EmbargoNotificationBehavior
      include ActionView::Helpers::UrlHelper

      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods
      end

      module ClassMethods
        def send_notification(work_id)
          notification = new(work_id)
          notification.call
          notification
        end
      end

      module InstanceMethods
        def initialize(work_id)
          @work = Etd.find(work_id)
          @user = ::User.find_by_user_key(@work.depositor)
          # Set the user email to the post-graduation email in this ETD,
          # just long enough to send this message. Don't save it, because
          # that should only happen at graduation. This is a safeguard just
          # in case the user email on file doesn't match what's in this ETD.
          @user.email = @work.post_graduation_email.first
          @message = message
          @subject = subject
        end

        # Truncate titles to 140 characters
        def title
          original_title = @work.title.first
          max = 140
          original_title.length > max ? "#{original_title[0...max]}..." : original_title
        end

        def call
          user = ::User.find_or_create_by(uid: WorkflowSetup::NOTIFICATION_OWNER)
          Rails.logger.warn "ETD #{@work.id}: embargo expiration notification sent to #{@user.email}: #{@subject}"
          recipients.each do |recipient|
            user.send_message(recipient, @message, @subject)
          end
        end

        # Send this to the depositor only
        def recipients
          Array.wrap(@user)
        end

        # Get the full URL for email notifications
        # This should get pushed upstream to Hyrax
        def document_url
          key = @work.model_name.singular_route_key
          Rails.application.routes.url_helpers.send(key + "_url", @work.id)
        end
      end
    end
  end
end
