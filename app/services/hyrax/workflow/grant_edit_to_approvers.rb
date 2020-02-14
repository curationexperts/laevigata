require 'workflow_setup'

module Hyrax
  module Workflow
    # This is a customized workflow step for Emory so their approvers can edit works
    module GrantEditToApprovers
      # @param [#read_users=, #read_users] target (likely an ActiveRecord::Base) to which we are adding edit_users for the depositor
      # @return void
      def self.call(target:, **)
        workflow = target.active_workflow
        approving_role = Sipity::Role.where(name: "approving").first
        wf_role = Sipity::WorkflowRole.find_by(workflow: workflow, role_id: approving_role)
        approving_agents = wf_role.workflow_responsibilities.pluck(:agent_id)
        sipity_agents = approving_agents.map { |a| Sipity::Agent.find(a).proxy_for_id }
        approving_users = sipity_agents.map { |a| ::User.find(a).user_key }
        target.edit_users += approving_users
        # If there are a lot of members, granting access to each could take a
        # long time. Do this work in the background.
        GrantEditToMembersJob.perform_later(target, target.depositor)
      end
    end
  end
end
