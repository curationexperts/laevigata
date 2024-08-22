# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  Hyrax::Workflow::PermissionQuery.class_eval do
    # original methods to be patched
    def scope_permitted_workflow_actions_available_for_current_state(user:, entity:)
      debugger
      workflow_actions_scope = scope_workflow_actions_available_for_current_state(entity: entity)
      workflow_state_actions_scope = scope_permitted_entity_workflow_state_actions(user: user, entity: entity)
      workflow_actions_scope.where(
        workflow_actions_scope.arel_table[:id].in(
          workflow_state_actions_scope.arel_table.project(
            workflow_state_actions_scope.arel_table[:workflow_action_id]
          ).where(workflow_state_actions_scope.constraints.reduce)
        )
      )
    end

    def scope_workflow_actions_available_for_current_state(entity:)
      workflow_actions_for_current_state = scope_workflow_actions_for_current_state(entity: entity)
      Sipity::WorkflowAction.where(workflow_actions_for_current_state.constraints.reduce)
    end
  end

end
