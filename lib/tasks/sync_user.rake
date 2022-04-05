require 'yaml'

namespace :emory do

  task sync_users: :environment do
    approvers = YAML.load(File.open(Rails.root.join('config', 'emory','admin_sets.yml')))
    superusers = YAML.load(File.open(Rails.root.join('config', 'emory','superusers.yml')))
    workflows = Sipity::Workflow.all
    approvers.values.each do |v|
      wf = workflows.find{|x| x.name = v['workflow'].first}
      users = v['approving'].map{|x| User.find_by(uid: x)}
      wf.update_responsibilities(role: Sipity::Role.find_by(name: 'approving'), agents: users.map(&:to_sipity_agent) )
    end
  end

end
