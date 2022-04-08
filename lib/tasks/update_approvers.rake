require 'yaml'

namespace :emory do
  task update_approvers: :environment do
    # create workflows
    WorkflowSetup.new.setup
    approvers = YAML.safe_load(File.open(Rails.root.join('config', 'emory', 'admin_sets.yml')))
    supers = YAML.safe_load(File.open(Rails.root.join('config', 'emory', 'superusers.yml')))
    superusers = supers.values.first.values.flatten.map { |x| User.find_by(uid: x).to_sipity_agent }
    admin_sets = AdminSet.all
    approving_role = Sipity::Role.find_by(name: 'approving')
    admin_sets.each do |as|
      users = if approvers.key? as.title.first
        uids = approvers[as.title.first]['approving']
        uids.map { |x| User.find_by(uid: x).to_sipity_agent }
              else
         []
              end
      Rails.logger.info "updating #{as.title.first}"
      as.active_workflow.update_responsibilities(role: approving_role, agents: users + superusers)
    end
  end
end
