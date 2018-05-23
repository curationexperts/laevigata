namespace :emory do
  desc 'Deduplicate PermissionTemplateAccesses'
  task :deduplicate_permission_template_accesses do
    ActiveRecord::Base.transaction do
      AdminSet.all.each do |admin_set|
        access_grants = Hyrax::PermissionTemplateAccess
                          .where(permission_template_id: admin_set.permission_template.id,
                                 agent_id:   'registered',
                                 access:     'deposit',
                                 agent_type: 'group').to_a

        access_grants.pop
        access_grants.each(&:destroy)
      end
    end
  end
end
