# frozen_string_literal: true

class PermissionChecker
  # Check whether a user has 'approving' role in any workflows
  # @return [Boolean]
  def self.sipity_approver?(user)
    return false unless user.is_a?(User) && user.persisted?

    user.to_sipity_agent.workflow_responsibilities.joins(workflow_role: :role)
        .where(sipity_roles: { name: Hyrax::RoleRegistry::APPROVING })
        .present?
  end

  # Check whether a user has the 'approving' role for an admin_set
  # @return [Boolean]
  def self.user_can_approve_admin_set?(user, admin_set)
    # ensure params are valid
    return false unless user.is_a?(User) && user.persisted?
    return false unless admin_set.is_a?(AdminSet) && admin_set.active_workflow.persisted?

    # bypass Sipity checks for Super Admins
    return true if user.admin?

    # Check Sipity workflows to see the if user is an approver for the admin set
    #
    # This long chain allows us to make a single database call for a complex set
    # of relations:
    # User --> Sipity::Agent
    #   --> Sipity::WorkflowResponsibility
    #     --> Sipity::WorkflowRole
    #       ?--> Siplity::Role (='approving')
    #       ?--> Sipity::Workflow (=admin_set.active_workflow)
    user.to_sipity_agent.workflow_responsibilities.joins(workflow_role: :role)
        .where(sipity_roles: { name: Hyrax::RoleRegistry::APPROVING },
               sipity_workflow_roles: { workflow_id: admin_set.active_workflow.id })
        .present?
  end
end
