require 'workflow_setup'

module Hyrax
  module Workflow
    # Notification to an individual that their ETD has been submitted to ProQuest.
    # Should notify work depositor only.
    class ProquestIndividualNotification
      def self.send_notification(work_id)
        ProquestIndividualNotification.new(work_id).call
      end

      def initialize(work_id)
        @work = Etd.find(work_id)
        @message = message
        @subject = subject
      end

      def message
        "As we indicated in the ETD submission form, your dissertation record will
        also be submitted to ProQuest, for publication in their Dissertation and
        Theses Database. With one potential exception, the term of embargo you
        requested in your ETD form will travel with your dissertation record, so
        any embargo on access to the whole file you requested in the ETD will also
        be implemented in the ProQuest database. The exception concerns the abstract:
        if you want your abstract to be embargoed in the ProQuest database, then you
        need to contact ProQuest and specifically request that. You can contact
        ProQuest at disspub@proquest.com, and they will honor your request. You
        might want to wait a week or so, since we are just now submitting your
        dissertation record, and it may take a few days to fully process it into
        their systems. (Note: if you requested an embargo of your table of contents
        in the ETD, there is nothing more you need to do, because this component
        of your record is not submitted to ProQuest.)"
      end

      def subject
        "Your work, #{@work.title.first}, has been submitted to ProQuest."
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
