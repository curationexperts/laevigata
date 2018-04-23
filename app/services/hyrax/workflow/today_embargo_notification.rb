module Hyrax
  module Workflow
    # Notification that embargo will expire today (or, more precisely, the same
    # day as the initialization date of the EmbargoExpirationService).
    # Should notify work depositor only.
    class TodayEmbargoNotification
      include ActionView::Helpers::UrlHelper
      def self.send_notification(work_id)
        notification = TodayEmbargoNotification.new(work_id)
        notification.call
        notification
      end

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

      def subject
        "Embargo on #{@work.title.first} expires today"
      end

      def message
        "Dear #{@user.display_name},\n\n" \
        "The access restriction on your disseration or thesis, #{@work.title.first}, expires today." \
        "We have not been informed that you wish to extend your access restriction period " \
        "and therefore your dissertation or thesis is now available in full text form in our repository.\n\n" \
        "Your dissertation or thesis can be accessed in the Emory University ETD Repository at: #{link_to document_url, document_url} \n\n" \
        "If you need your record to remain restricted/embargoed, please contact etd-help@listserv.cc.emory.edu<mailto:etd-help@listserv.cc.emory.edu> with your request. \n\n" \
        "Please do not reply directy to this email.\n\n" \

        "FOR AUTHORS WHO ALSO SUBMITTED TO PROQUEST:\n" \
        "To extend your access restriction/embargo in the ProQuest database, you " \
        "will need to contact ProQuest's Author Relations department to request " \
        "they extend your embargo. You can reach them at 1-800-521-0600 ext. 77020 " \
        "or via email at disspub@proquest.com<mailto:disspub@proquest.com>."
      end

      def call
        user = ::User.find_or_create_by(uid: WorkflowSetup::NOTIFICATION_OWNER)
        Rails.logger.warn "ETD #{@work.id}: embargo expiration today notification sent to #{@user.email}"
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
