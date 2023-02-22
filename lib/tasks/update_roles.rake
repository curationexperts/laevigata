require 'yaml'

namespace :emory do
  desc "Update AdminSets and associated approvers"
  task update_roles: :environment do
    # create workflows
    WorkflowSetup.new.setup
    approvers = YAML.safe_load(File.open(Rails.root.join('config', 'emory', 'admin_sets.yml')))
    supers = YAML.safe_load(File.open(Rails.root.join('config', 'emory', 'superusers.yml')))
    superusers = supers.values.first.values.flatten.map { |x| User.find_by(uid: x).to_sipity_agent }
    admin_sets = AdminSet.all
    sip_roles = Sipity::Role.all
    admin_sets.each do |as|
      sip_roles.each do |role|
        users = if approvers.key? as.title.first
                  uids = approvers[as.title.first][role.name] || []
                  uids.map { |x| User.find_by(uid: x).to_sipity_agent }
                else
                  []
                end
        as.active_workflow.update_responsibilities(role: role, agents: users + superusers)
      end
    end
  end
end
