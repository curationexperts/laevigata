module Hyrax
  module Workflow
    class LaevigataNotification < AbstractNotification
      # regardless of what is passed in, set the recipients according to this notification's requirements
      def initialize(entity, comment, user, recipients)
        super
        @recipients = workflow_recipients
      end

      def workflow_recipients
        raise NotImplementedError, "Implement workflow_recipients in a child class"
      end

      # The Users who have an approving role for the relevant workflow
      # @return [<Array>::User] an Array of Hyrax::User objects
      def approvers
        approvers = []
        approving_role = Sipity::Role.find_by!(name: "approving")
        wf_role = Sipity::WorkflowRole.find_by(workflow: document.active_workflow, role_id: approving_role)
        wf_role.workflow_responsibilities.pluck(:agent_id).each do |agent_id|
          approvers << Sipity::Agent.where(id: agent_id).pluck(:proxy_for_id).map { |proxy_for_id| ::User.find(proxy_for_id) }.first
        end
        approvers
      end

      # The Users who have a reviewing role for the relevant workflow
      # @return [<Array>::User] an Array of Hyrax::User objects
      def reviewers
        reviewers = []
        reviewing_role = Sipity::Role.find_by!(name: "reviewing")
        wf_role = Sipity::WorkflowRole.find_by(workflow: document.active_workflow, role_id: reviewing_role)
        wf_role.workflow_responsibilities.pluck(:agent_id).each do |agent_id|
          reviewers << Sipity::Agent.where(id: agent_id).pluck(:proxy_for_id).map { |proxy_for_id| ::User.find(proxy_for_id) }.first
        end
        reviewers
      end

      # The Hyrax::User who desposited the work
      # @return [Hyrax::User]
      def depositor
        ::User.where(ppid: document.depositor).first
      end
    end
  end
end
