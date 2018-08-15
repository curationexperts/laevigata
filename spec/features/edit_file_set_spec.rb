# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Edit an existing FileSet', :clean, :perform_jobs, integration: true, workflow: { admin_sets_config: 'spec/fixtures/config/emory/admin_sets_small.yml' } do
  let(:student) { create :user }
  let(:approver) { User.find_by_uid("tezprox") }

  let(:primary_pdf_file) { FactoryBot.create(:primary_uploaded_file, user_id: student.id) }

  let(:etd) { FactoryBot.build(:etd, etd_attrs) }
  let(:etd_attrs) do
    {
      title: ['ETD title'],
      depositor: student.user_key,
      school: ['Emory College'],
      department: ['Art History']
    }
  end

  before do
    ActiveJob::Base.queue_adapter.filter = [AttachFilesToWorkJob]

    # Create ETD & attach PDF file
    etd.assign_admin_set
    attributes_for_actor = { uploaded_files: [primary_pdf_file.id] }
    env = Hyrax::Actors::Environment.new(etd, ::Ability.new(student), attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)

    # Approver requests changes, so student will be able to edit the file_set
    change_workflow_status(etd, "request_changes", approver)
  end

  context 'a student' do
    before { login_as student }

    it 'renders the edit form' do
      visit main_app.edit_hyrax_file_set_path(etd.primary_file_fs.first.id)
      expect(find_field('Title').value).to eq 'ETD title'
    end
  end
end
