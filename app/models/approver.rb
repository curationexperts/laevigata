# frozen_string_literal: true

class Approver
  # For a given AdminSet, which Users are approvers for the active workflow.
  def self.for_admin_set(admin_set)
    workflow = admin_set.active_workflow
    approving_role = Sipity::Role.where(name: "approving").first
    wf_role = Sipity::WorkflowRole.find_by(workflow: workflow, role_id: approving_role)
    resp = wf_role.workflow_responsibilities
    agents = Sipity::Agent.where(id: resp.pluck(:agent_id), proxy_for_type: 'User')
    user_ids = agents.pluck('proxy_for_id')

    User.find user_ids
  end
end
