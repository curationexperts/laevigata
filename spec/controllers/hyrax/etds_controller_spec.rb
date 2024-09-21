# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdsController, :perform_jobs do
  before :all do
    ActiveFedora::Cleaner.clean!
    # ensure clean! is called before rather than after WorkflowSetup - i.e. avoid using use :clean tag
    WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null").setup
  end

  let(:user) { create :user }
  let(:approver) { User.where(uid: "tezprox").first }

  let(:file1) { File.open("#{fixture_path}/miranda/miranda_thesis.pdf") }
  let(:file2) { File.open("#{fixture_path}/magic_warrior_cat.jpg") }
  let(:file3) { File.open("#{fixture_path}/miranda/rural_clinics.zip") }

  let(:supp_file_attrs) do
    { user: user,
      pcdm_use: 'supplementary',
      title: 'supp file title',
      description: 'supp file desc',
      file_type: 'Image' }
  end

  before do
    # Don't characterize the file during specs
    allow(CharacterizeJob).to receive_messages(perform_later: nil, perform_now: nil)

    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    sign_in user
  end

  describe "#update" do
    let(:default_attrs) do
      { depositor: user.user_key,
        title: ['Another great thesis by Frodo'],
        school: ['Emory College'],
        department: ['Art History'] }
    end
    let(:etd) do
      FactoryBot.build(:etd, default_attrs)
    end

    before do
      etd.assign_admin_set

      # Create the ETD record
      env = Hyrax::Actors::Environment.new(etd, ::Ability.new(user), {})
      middleware = Hyrax::DefaultMiddlewareStack.build_stack.build(Hyrax::Actors::Terminator.new)
      middleware.create(env)

      # Approver requests changes, so student will be able to edit the ETD
      change_workflow_status(etd, "request_changes", approver)

      etd.reload
    end

    context 'editing or removing committee members and chairs' do
      let(:etd) { FactoryBot.build(:etd, default_attrs.merge(committee_chair_attributes: [arthur, lancelot], committee_members_attributes: [morgan, guin])) }

      let(:arthur) { { name: ['Arthur'], affiliation: ['Emory University'] } }
      let(:lancelot) { { name: ['Lancelot'], affiliation: ['Another University'] } }
      let(:morgan) { { name: ['Morgan'], affiliation: ['Emory University'] } }
      let(:guin) { { name: ['Guinevere'], affiliation: ['Another University'] } }

      let(:new_attrs) do
        {
          committee_chair_attributes: { '0' => new_arthur },
          committee_members_attributes: { '0' => new_morgan }
        }
      end

      let(:new_arthur) { { name: ['Arthur (edited)'], affiliation: ['Edited University'] } }
      let(:new_morgan) { { name: ['Morgan (edited)'], affiliation: ['Emory University'] } }

      before do
        patch :update, params: { id: etd, etd: new_attrs, request_from_form: 'true' }
        etd.reload # Test persisted state
      end

      it 'updates committee members and chairs' do
        expect(etd.committee_chair.count).to eq 1
        expect(etd.committee_chair.first.name).to eq ['Arthur (edited)']
        expect(etd.committee_chair.first.affiliation).to eq ['Edited University']

        expect(etd.committee_members.count).to eq 1
        expect(etd.committee_members.first.name).to eq ['Morgan (edited)']
        expect(etd.committee_members.first.affiliation).to eq ['Emory University']
      end
    end

    context 'adding a new supplemental file' do
      let(:uf) { FactoryBot.create(:uploaded_file, :supplementary, title: ['old uf title'], user_id: user.id) }

      let(:supp_file_meta) do
        { "0" => {
          "filename" => "joey_thesis.pdf",
            "title" => "new uf title",
            "description" => "uf desc",
            "file_type" => "Image"
        } }
      end

      before do
        # For this test we don't need to create the actual Etd record, so stub out the actor.
        test_actor = double(update: true)
        allow(Hyrax::CurationConcern).to receive(:actor).and_return(test_actor)
        allow(controller).to receive(:actor_environment)

        patch :update, params: { id: etd, etd: { supplemental_file_metadata: supp_file_meta }, uploaded_files: [uf.id], request_from_form: 'true' }
        uf.reload
      end

      it 'updates the Hyrax::UploadedFile record with the metadata, so that metadata will be applied when the file is attached to the Etd record' do
        expect(uf.title).to eq 'new uf title'
        expect(uf.description).to eq 'uf desc'
        expect(uf.file_type).to eq 'Image'
      end
    end

    context 'new data submitted from the form' do
      let(:actor) { Hyrax::CurationConcern.actor }
      it 'updates the ETD and returns json redirect path' do
        patch :update, params: { id: etd.id, etd: { title: 'New Title' }, request_from_form: 'true' }

        etd.reload
        expect(etd.title).to eq ['New Title']

        redir_path = JSON.parse(response.body)['redirectPath'].split('?').first
        expect(redir_path).to eq main_app.hyrax_etd_path(etd).split('?').first
      end

      it 'reports error' do
        allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
        # Stub an unsuccessful update
        allow(actor).to receive(:update).and_return(false)
        patch :update, params: { id: etd.id, etd: { title: 'New Title' }, request_from_form: 'true' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST create" do
    it "creates an etd" do
      expect {
        post :create, params: { etd: { title: 'a title', school: 'Emory College', department: 'Art History' } }
      }.to change { Etd.count }.by(1)
      assert_redirected_to main_app.hyrax_etd_path(assigns[:curation_concern], locale: 'en')
    end

    context 'with an associated InProgressEtd record' do
      let!(:ipe) { InProgressEtd.create }

      before do
        allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
      end

      context 'when the Etd record creation is successful' do
        let(:actor) { double(create: true) }

        it 'deletes the InProgressEtd record' do
          expect {
            post :create, params: { etd: { ipe_id: ipe.id } }
          }.to change { InProgressEtd.count }.by(-1)
        end
      end

      context 'when the Etd record creation fails' do
        let(:actor) { double(create: false) }

        it 'keeps the InProgressEtd record' do
          expect {
            post :create, params: { etd: { ipe_id: ipe.id } }
          }.to change { Etd.count }.by(0)
        end

        it "returns a 422 status to the user" do
          post :create, params: { etd: { ipe_id: ipe.id } }

          expect(response.status).to eq(422)
        end

        it "returns a json error to the user" do
          post :create, params: { etd: { ipe_id: ipe.id } }

          expect(response.body).to include('errors')
        end
      end

      context "when a StandardError is raised" do
        let(:actor) { double(create: false) }

        it "returns an error message to the user" do
          allow(actor).to receive(:create).and_raise('Cannot find admin set config where school = and department = ')
          post :create, params: { etd: { ipe_id: ipe.id } }

          expect(response.body).to include('Cannot find admin set config where school = and department = ')
        end

        it "logs the error and user" do
          allow(actor).to receive(:create).and_raise('StandardError')
          expect(Rails.logger).to receive(:error).with("Create from IPE error: StandardError, current_user: #{user}")

          post :create, params: { etd: { ipe_id: ipe.id } }
        end
      end
    end
  end

  describe "supplemental file metadata" do
    let(:params) do
      {
        "etd" => {
          "title" => "My Title",
          "no_supplemental_files" => "0",
          "supplemental_file_metadata" => {
            "0" => {
              "filename" => "magic_warrior_cat.jpg",
              "title" => "Magic Warrior Cat",
              "description" => "she's magic!",
              "file_type" => "Image"
            },
            "1" => {
              "filename" => "rural_clinics.zip",
              "title" => "Rural Clinics Shapefile",
              "description" => "rural clinics in Georgia",
              "file_type" => "Data"
            }
          }
        },
        "uploaded_files" => ["14", "15", "16"],
        "save_with_files" => "Save",
        "locale" => "en"
      }
    end
    before do
      Hyrax::UploadedFile.delete_all
      FactoryBot.create(:uploaded_file, id: 14, file: file1, user_id: user.id, pcdm_use: "primary")
      FactoryBot.create(:uploaded_file, id: 15, file: file2, user_id: user.id)
      FactoryBot.create(:uploaded_file, id: 16, file: file3, user_id: user.id)
    end
    it "attaches metadata to uploaded files" do
      described_class.new.apply_file_metadata(params)
      file15 = Hyrax::UploadedFile.find(15)
      file16 = Hyrax::UploadedFile.find(16)
      expect(file15.title).to eq("Magic Warrior Cat")
      expect(file15.description).to eq("she's magic!")
      expect(file15.file_type).to eq("Image")

      expect(file16.title).to eq("Rural Clinics Shapefile")
      expect(file16.description).to eq("rural clinics in Georgia")
      expect(file16.file_type).to eq("Data")
    end
  end

  describe '#document_not_found!' do
    let(:guest_user) { User.new(ppid: 'GUEST_USER') }
    let(:etd) { FactoryBot.create(:etd, depositor: user.ppid) }

    it 'override blocks access for non-depositors' do
      allow(controller).to receive(:current_user).and_return(guest_user)
      allow(SolrDocument).to receive(:find).and_return(SolrDocument.new(etd.to_solr))
      controller.params = ActionController::Parameters.new("id" => etd.id)

      expect { controller.document_not_found! }.to raise_exception(CanCan::AccessDenied)
    end
  end
end
