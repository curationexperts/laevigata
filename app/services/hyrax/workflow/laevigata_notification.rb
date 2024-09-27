module Hyrax
  module Workflow
    class LaevigataNotification < AbstractNotification
      # regardless of what is passed in, set the recipients according to this notification's requirements
      def initialize(entity, comment, user, recipients = {})
        recipients ||= {} # provide default value when `nil` is explictly passed
        super
        @recipients = workflow_recipients.with_indifferent_access
      end

      def self.send_notification(entity:, comment:, user:, recipients: {})
        super
      end

      # Truncate titles to 140 characters
      def title
        document.title.first.truncate(140, separator: /\s/)
      end

      # Get the full URL for email notifications
      # This should get pushed upstream to Hyrax
      def document_url
        Rails.application.routes.url_helpers.url_for(document)
      end

      def workflow_recipients
        raise NotImplementedError, "Implement workflow_recipients in a child class"
      end

      # The Users who have an approving role for the relevant workflow
      # @return [<Array>::User] an Array of Hyrax::User objects
      def approvers
        users_for(role_name: 'approving')
      end

      # The Users who have a reviewing role for the relevant workflow
      # @return [<Array>::User] an Array of Hyrax::User objects
      def reviewers
        users_for(role_name: 'reviewing')
      end

      # The Hyrax::User who desposited the work
      # @return [Hyrax::User]
      def depositor
        ::User.find_by(ppid: document.depositor)
      end

      private

        def users_for(role_name:)
          role = Sipity::Role.find_by!(name: role_name)
          wf_role = Sipity::WorkflowRole.find_by(workflow: document.active_workflow, role_id: role)
          agents  = Sipity::Agent.where(id: wf_role.workflow_responsibilities.pluck(:agent_id))
          users   = agents.where(proxy_for_type: 'User').pluck(:proxy_for_id)

          ::User.find(users)
        end
    end
  end
end
