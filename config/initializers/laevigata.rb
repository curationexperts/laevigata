require 'workflow_setup'
Rails.application.config.after_initialize do
  w = WorkflowSetup.new
  w.make_mediated_deposit_admin_set("School One")
  w.make_mediated_deposit_admin_set("School Two")
  w.make_mediated_deposit_admin_set("School Three")
  w.make_mediated_deposit_admin_set("School Four")
end
