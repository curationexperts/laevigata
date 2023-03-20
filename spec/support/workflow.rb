module Workflow
  def change_workflow_status(etd, action_name, user, comment = nil)
    subject = Hyrax::WorkflowActionInfo.new(etd, user)
    sipity_workflow_action = PowerConverter.convert_to_sipity_action(action_name, scope: subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: comment)
  end
end

RSpec.configure do |config|
  config.include Workflow
end
