module Hyrax
  module Workflow
    # Notification that embargo will expire seven days from today.
    # Should notify work depositor only
    class SevenDayEmbargoNotification
      include EmbargoNotificationBehavior
      CONTACT_LINK = 'https://libraries.emory.edu/research/open-access-publishing/emory-repositories-policy/etd/contact'.freeze

      def subject
        "Embargo on #{title} will expire in seven days"
      end

      def message
        %(
        Dear #{@user.display_name},\n\n
        The embargo on your dissertation or thesis, #{title}, will expire in seven days.
        Your dissertation or thesis can be accessed in the Emory University ETD Repository at: #{link_to document_url, document_url}

        If you need your record to remain restricted/embargoed, please contact your school administrators
        located here: #{link_to CONTACT_LINK, CONTACT_LINK} with your request. \n\n
        Please do not reply directly to this email.

        FOR AUTHORS WHO ALSO SUBMITTED TO PROQUEST:
        To extend your access restriction/embargo in the ProQuest database, you
        will need to contact ProQuest's Author Relations department to request
        an extended access restriction/embargo in their database. You can reach them at 1-800-521-0600 ext. 2
        or via email at disspub@proquest.com<mailto:disspub@proquest.com>.
      )
      end
    end
  end
end
