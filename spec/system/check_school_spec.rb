require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Check for school', :clean, integration: true, js: true, type: :system do
  let(:user) { create :user }

  let(:approver) { User.where(uid: "tezprox").first }

  before do
    allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(true)
  end

  describe 'verify school is Emory College' do
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
      scenario 'school does not change when etd is in request_changes status' do
        # Changes are requested for ETD
        change_workflow_status(ec_etd, "request_changes", approver)

        ec_etd.reload

        visit("/concern/etds/#{ec_etd.id}")

        expect(find('.attribute-school').text).to eq 'Emory College'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Emory College'
        expect(find('.no-edit-school-name').text).to eq 'Emory College'
      end

      scenario 'school does not change when etd is in approved status' do
        # ETD is approved
        change_workflow_status(ec_etd, "approve", approver)

        ec_etd.reload

        visit("/concern/etds/#{ec_etd.id}")

        expect(find('.attribute-school').text).to eq 'Emory College'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Emory College'
        expect(find('.no-edit-school-name').text).to eq 'Emory College'
      end

      scenario 'school does not change when etd is in published status' do
        # ETD is published
        change_workflow_status(ec_etd, "publish", approver)

        ec_etd.reload

        visit("/concern/etds/#{ec_etd.id}")

        expect(find('.attribute-school').text).to eq 'Emory College'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Emory College'
        expect(find('.no-edit-school-name').text).to eq 'Emory College'
      end
    end
  end

  describe 'verify school is Candler School of Theology' do
    let(:default_attrs) do
      { depositor: user.user_key,
        title: ['This is another thesis'],
        school: ['Candler School of Theology'],
        department: ['Divinity'] }
    end
    let(:candler_etd) do
      FactoryBot.build(:etd, default_attrs)
    end

    let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null") }

    before do
      workflow_setup.setup
      candler_etd.assign_admin_set

      # Create the ETD record
      env = Hyrax::Actors::Environment.new(candler_etd, ::Ability.new(user), {})
      middleware = Hyrax::DefaultMiddlewareStack.build_stack.build(Hyrax::Actors::Terminator.new)
      middleware.create(env)

      login_as approver
    end

    context 'when editing an etd' do
      scenario 'school does not change when etd is in request_changes status' do
        # Changes are requested for ETD
        change_workflow_status(candler_etd, "request_changes", approver)

        candler_etd.reload

        visit("/concern/etds/#{candler_etd.id}")

        expect(find('.attribute-school').text).to eq 'Candler School of Theology'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Candler School of Theology'
        expect(find('.no-edit-school-name').text).to eq 'Candler School of Theology'
      end

      scenario 'school does not change when etd is in approved status' do
        # ETD is approved
        change_workflow_status(candler_etd, "approve", approver)

        candler_etd.reload

        visit("/concern/etds/#{candler_etd.id}")

        expect(find('.attribute-school').text).to eq 'Candler School of Theology'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Candler School of Theology'
        expect(find('.no-edit-school-name').text).to eq 'Candler School of Theology'
      end

      scenario 'school does not change when etd is in published status' do
        # ETD is published
        change_workflow_status(candler_etd, "publish", approver)

        candler_etd.reload

        visit("/concern/etds/#{candler_etd.id}")

        expect(find('.attribute-school').text).to eq 'Candler School of Theology'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Candler School of Theology'
        expect(find('.no-edit-school-name').text).to eq 'Candler School of Theology'
      end
    end
  end

  describe 'verify school is Laney Graduate School' do
    let(:default_attrs) do
      { depositor: user.user_key,
        title: ['This is one more thesis'],
        school: ['Laney Graduate School'],
        department: ['Anthropology'] }
    end
    let(:laney_etd) do
      FactoryBot.build(:etd, default_attrs)
    end

    let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }

    before do
      workflow_setup.setup
      laney_etd.assign_admin_set

      # Create the ETD record
      env = Hyrax::Actors::Environment.new(laney_etd, ::Ability.new(user), {})
      middleware = Hyrax::DefaultMiddlewareStack.build_stack.build(Hyrax::Actors::Terminator.new)
      middleware.create(env)

      login_as approver
    end

    context 'when editing an etd' do
      scenario 'school does not change when etd is in request_changes status' do
        # Changes are requested for ETD
        change_workflow_status(laney_etd, "request_changes", approver)

        laney_etd.reload

        visit("/concern/etds/#{laney_etd.id}")

        expect(find('.attribute-school').text).to eq 'Laney Graduate School'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Laney Graduate School'
        expect(find('.no-edit-school-name').text).to eq 'Laney Graduate School'
      end

      scenario 'school does not change when etd is in approved status' do
        # ETD is approved
        change_workflow_status(laney_etd, "approve", approver)

        laney_etd.reload

        visit("/concern/etds/#{laney_etd.id}")

        expect(find('.attribute-school').text).to eq 'Laney Graduate School'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Laney Graduate School'
        expect(find('.no-edit-school-name').text).to eq 'Laney Graduate School'
      end

      scenario 'school does not change when etd is in published status' do
        # ETD is published
        change_workflow_status(laney_etd, "publish", approver)

        laney_etd.reload

        visit("/concern/etds/#{laney_etd.id}")

        expect(find('.attribute-school').text).to eq 'Laney Graduate School'

        click_on("Edit")

        expect(find(:css, 'input[name="etd[school]"]', visible: false, match: :first).value).to eq 'Laney Graduate School'
        expect(find('.no-edit-school-name').text).to eq 'Laney Graduate School'
      end
    end
  end
end
