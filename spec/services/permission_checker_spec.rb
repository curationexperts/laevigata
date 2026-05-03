require 'rails_helper'

RSpec.describe PermissionChecker, use_transactional_tests: false do
  before(:all) do
    # Workflow setup is extremely expensive (i.e. makes many, many slow database calls).
    # The tests we want to run are essentially read-only access checks.
    # So, the state of our workflows does not change between tests
    # Therefore, we're explicitly setting up workflows once before all tests and
    # then rolling back changes after all tests have executed.

    # Wrap the entire context in a transaction
    ActiveRecord::Base.connection.begin_transaction

    # Remove any pre-existing AdminSets
    AdminSet.all.each do |admin_set|
      admin_set.delete
      ActiveFedora::Base.eradicate(admin_set.id)
    end

    # Set Up Workflows
    Hyrax::Workflow::WorkflowImporter.path_to_workflow_files = "#{fixture_path}/config/workflows/minimal_one_step_approval.json"
    WorkflowSetup.new("#{fixture_path}/config/emory/superusers_db_only.yml", "#{fixture_path}/config/emory/admin_sets_school_department.yml", "/dev/null").setup
  end

  after(:all) do
    # Roll back the transaction started in before(:all)
    ActiveRecord::Base.connection.rollback_transaction if ActiveRecord::Base.connection.transaction_open?
    Hyrax::Workflow::WorkflowImporter.path_to_workflow_files = Rails.root.join('config', 'workflows', '*.json')
  end

  describe '.has_approver_role?' do
    let(:permission_check) { ->(user) { described_class.sipity_approver?(user) } }

    example 'for super_admins' do
      super_admin = User.find_by(uid: 'super_admin')
      expect(described_class.sipity_approver?(super_admin)).to be true
    end

    example 'for workflow-level approvers' do
      department_admin = User.find_by(uid: 'department_approver')
      expect(described_class.sipity_approver?(department_admin)).to be true
    end

    example 'for regular users' do
      student_user = FactoryBot.create(:user)
      expect(described_class.sipity_approver?(student_user)).to be false
    end

    example 'for unsaved users' do
      new_user = FactoryBot.build(:user)
      expect(described_class.sipity_approver?(new_user)).to be false
    end
  end

  describe '.user_can_approve_admin_set?' do
    let(:permission_check) { ->(user, admin_set) { described_class.user_can_approve_admin_set?(user, admin_set) } }

    context 'for super_admins' do
      let(:super_admin) { User.find_by(uid: 'super_admin') }
      let(:admin_set) { AdminSet.where(title: 'Applied Epidemiology').first }
      it 'can approve any admin set' do
        expect(permission_check.call(super_admin, admin_set)).to be true
      end
    end

    context 'for admin set approvers' do
      let(:school_admin) { User.find_by(uid: 'school_approver') }
      let(:admin_set) { AdminSet.where(title: 'Emory College').first }
      it 'can approve associated admin set' do
        expect(permission_check.call(school_admin, admin_set)).to be true
      end
    end

    context 'for other approvers' do
      let(:department_admin) { User.find_by(uid: 'department_approver') }
      let(:admin_set) { AdminSet.where(title: 'Emory College').first }
      it 'can NOT approve other admin sets' do
        expect(permission_check.call(department_admin, admin_set)).to be false
      end
    end

    context 'for regular users' do
      let(:student_user) { FactoryBot.create(:user) }
      let(:admin_set) { AdminSet.where(title: 'Emory College').first }
      it 'can NOT approve other admin sets' do
        expect(permission_check.call(student_user, admin_set)).to be false
      end
    end

    context 'for tranient users' do
      let(:admin_set) { AdminSet.where(title: 'Emory College').first }
      it 'can NOT approve admin sets' do
        expect(permission_check.call(User.new, admin_set)).to be false
      end
    end

    context 'when user is invalid' do
      let(:user) { Hyrax::Group.new('Not a User') } # i.e. anything that is no a User
      let(:admin_set) { AdminSet.where(title: 'Emory College').first }
      it 'returns false' do
        expect(permission_check.call(user, admin_set)).to be false
      end
    end

    context 'when admin set is invalid' do
      let(:super_admin) { FactoryBot.build(:admin) }
      let(:admin_set) { InProgressEtd.new } # i.e. anything that is not an AdminSet
      it 'returns false' do
        expect(permission_check.call(super_admin, admin_set)).to be false
      end
    end
  end
end
