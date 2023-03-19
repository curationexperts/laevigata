# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Selected school', :clean, integration: true, js: true, type: :system do
  let(:user) { create :user }

  let(:approver) { User.where(uid: "tezprox").first }

  before do
    allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(true)
  end

  describe 'does not change' do
    let(:default_attrs) do
      { depositor: user.user_key,
        title: ['This is a thesis'],
        school: ['Emory College'],
        department: ['Art History'] }
    end
    let(:ec_etd) do
      FactoryBot.build(:etd, default_attrs)
    end

    let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }

    before do
      workflow_setup.setup
      ec_etd.assign_admin_set

      # Create the ETD record
      env = Hyrax::Actors::Environment.new(ec_etd, ::Ability.new(user), {})
      middleware = Hyrax::DefaultMiddlewareStack.build_stack.build(Hyrax::Actors::Terminator.new)
      middleware.create(env)

      login_as approver
    end

    context 'when editing an etd' do
      scenario 'in request_changes status' do
        # Changes are requested for ETD
        change_workflow_status(ec_etd, "request_changes", approver)

        visit("/concern/etds/#{ec_etd.id}")

        expect(find('.attribute-school').text).to eq 'Emory College'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Emory College'
        expect(find('.no-edit-school-name').text).to eq 'Emory College'
      end

      scenario 'in approved status' do
        # ETD is approved
        change_workflow_status(ec_etd, "approve", approver)

        visit("/concern/etds/#{ec_etd.id}")

        expect(find('.attribute-school').text).to eq 'Emory College'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Emory College'
        expect(find('.no-edit-school-name').text).to eq 'Emory College'
      end

      scenario 'in published status' do
        # ETD is published
        change_workflow_status(ec_etd, "publish", approver)

        visit("/concern/etds/#{ec_etd.id}")

        expect(find('.attribute-school').text).to eq 'Emory College'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Emory College'
        expect(find('.no-edit-school-name').text).to eq 'Emory College'
      end
    end
  end
end
