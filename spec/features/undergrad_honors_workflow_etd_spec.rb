# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Emory College approval workflow', :perform_jobs, :clean, :js, integration: true, workflow: { admin_sets_config: 'spec/fixtures/config/emory/ec_admin_sets.yml' } do
  let(:depositing_user) { User.where(ppid: etd.depositor).first }
  let(:ability) { ::Ability.new(depositing_user) }
  let(:approving_user) { User.find_by_uid("ecadmin") }
  let(:admin_user) { User.find_by_uid('wonderwoman001') }
  let(:etd) { FactoryBot.create(:sample_data, school: ["Emory College"]) }
  let(:attributes) { {} }
  let(:env) { Hyrax::Actors::Environment.new(etd, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:middleware) do
    Hyrax::DefaultMiddlewareStack.build_stack.build(terminator)
  end

  context 'a logged in user' do
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      middleware.create(env)
    end
    scenario "a school approver approves a work" do
      expect(etd.active_workflow.name).to eq "emory_one_step_approval"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_approval"

      # Check workflow permissions for depositing user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: depositing_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq false
      expect(available_workflow_actions.include?("approve")).to eq false
      expect(available_workflow_actions.include?("request_changes")).to eq false
      expect(available_workflow_actions.include?("comment_only")).to eq false
      expect(available_workflow_actions.include?("hide")).to eq false
      expect(available_workflow_actions.include?("unhide")).to eq false

      # Check notifications for depositing user
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was deposited by #{depositing_user.display_name} and is awaiting approval."

      # Check notifications for approving user
      logout
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was deposited by #{depositing_user.display_name} and is awaiting approval."

      # Check workflow permissions for approving user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: approving_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq false # this workflow step should only exist for Laney
      expect(available_workflow_actions.include?("approve")).to eq true
      expect(available_workflow_actions.include?("request_changes")).to eq true
      expect(available_workflow_actions.include?("comment_only")).to eq true
      expect(available_workflow_actions.include?("hide")).to eq true
      expect(available_workflow_actions.include?("unhide")).to eq true

      # Last superuser should have all workflow options available. (First superuser gets these by virtue of owning the admin sets.)
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: admin_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq false # this workflow step should only exist for Laney
      expect(available_workflow_actions.include?("approve")).to eq true
      expect(available_workflow_actions.include?("request_changes")).to eq true
      expect(available_workflow_actions.include?("comment_only")).to eq true
      expect(available_workflow_actions.include?("hide")).to eq true
      expect(available_workflow_actions.include?("unhide")).to eq true

      # The approving user marks the etd as approved
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved"

      # Check notifications for approving user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first}\" deposited by #{depositing_user.display_name} has been approved by"

      # Check notifications for depositor again
      logout
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first}\" deposited by #{depositing_user.display_name} has been approved by"

      # Depositing user should be able to see their work, even if it hasn't been approved yet
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content(etd.abstract.first)
      expect(page).not_to have_content("The work is not currently available because it has not yet completed the publishing process")

      # Visit the ETD as a public user. It should not be visible.
      logout
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "The work is not currently available because it has not yet completed the publishing process"

      # Run the graduation service
      allow(GraduationService).to receive(:check_degree_status).and_return(Time.zone.today)
      GraduationService.run

      # Now the work should be publicly visible
      visit("/concern/etds/#{etd.id}")
      expect(page).not_to have_content "The work is not currently available because it has not yet completed the publishing process"

      # Check for graduation notifications
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "Degree awarded for #{etd.title.first}"

      # Check graduation notifications for approving user
      logout
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content "Degree awarded for #{etd.title.first}"
    end
  end
end
