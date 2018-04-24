module Hyrax
  module Workflow
    # Notification that embargo will expire sixty days from today.
    # Should notify work depositor only
    class SixtyDayEmbargoNotification
      include EmbargoNotificationBehavior

      def subject
        "Embargo on #{title} will expire in sixty days"
      end

      def message
        "Dear #{@user.display_name},\n\n" \
        "The embargo on your dissertation or thesis, #{title}, will expire in sixty days.\n" \
        "Your dissertation or thesis can be accessed in the Emory University ETD Repository at: #{link_to document_url, document_url} \n\n" \
        "If you need your record to remain restricted/embargoed, please contact etd-help@listserv.cc.emory.edu<mailto:etd-help@listserv.cc.emory.edu> with your request. \n\n" \
        "Please do not reply directy to this email.\n\n" \

        "FOR AUTHORS WHO ALSO SUBMITTED TO PROQUEST:\n" \
        "To extend your access restriction/embargo in the ProQuest database, you " \
        "will need to contact ProQuest's Author Relations department to request " \
        "they extend your embargo. You can reach them at 1-800-521-0600 ext. 77020 " \
        "or via email at disspub@proquest.com<mailto:disspub@proquest.com>."
      end
    end
  end
end
