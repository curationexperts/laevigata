namespace :emory do
  desc "Set up certain approvers in QA environment"
  task qa_approver_setup: :environment do
    Rails.logger.warn "Registering QA approvers"
    add_approver(admin_set_title: "Candler School of Theology", approver_uid: "jdoty")
  end

  def add_approver(admin_set_title:, approver_uid:)
    u = ::User.find_or_create_by(uid: approver_uid)
    u.password = "123456" if set_default_password?
    u.provider = "shibboleth"
    u.ppid = approver_uid # temporary ppid, will get replaced when user signs in with shibboleth
    u.save
    approving_users = [u]
    admin_set = AdminSet.where(title: admin_set_title).first
    approval_role = Sipity::Role.find_by!(name: 'approving')
    workflow = admin_set.active_workflow
    workflow.update_responsibilities(role: approval_role, agents: (approving_users.concat users_in_role(admin_set, "approving")))
    if workflow.workflow_roles.map { |workflow_role| workflow_role.role.name }.include?("reviewing")
      reviewing_role = Sipity::Role.find_by!(name: 'reviewing')
      workflow.update_responsibilities(role: reviewing_role, agents: (approving_users.concat users_in_role(admin_set, "reviewing")))
    end
    message = "Added #{approver_uid} as an approver in #{admin_set_title}"
    Rails.logger.warn message
    puts message
  end

  # Don't set default passwords in production mode
  def set_default_password?
    AuthConfig.use_database_auth? && !Rails.env.production?
  end

  # Given an admin set and a role, return relevant Array of Sipity::Users for the
  # currently active workflow
  # @param [AdminSet] admin_set
  # @param [String|Sipity::Role] role e.g., "approving" "depositing" "managing"
  # @return [Array<Sipity::Agent>] An array of Sipity::Agent objects
  def users_in_role(admin_set, role)
    return [] unless admin_set.permission_template.available_workflows.exists?(active: true)

    role     = Sipity::Role.find_by!(name: role) unless role.is_a?(Sipity::Role)
    workflow = admin_set.permission_template.available_workflows.find_by(active: true)
    wf_role  = Sipity::WorkflowRole.find_by(workflow: workflow, role_id: role)
    return [] unless wf_role

    Sipity::Agent.where(id: wf_role.workflow_responsibilities.pluck(:agent_id),
                        proxy_for_type: 'User').to_a
  end
end
