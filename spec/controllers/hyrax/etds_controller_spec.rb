# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdsController, :perform_jobs, :clean do
  let(:user) { create :user }

  let(:approver) { User.where(uid: "tezprox").first }
  let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }

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
      workflow_setup.setup
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
        new_ui = Rails.application.config_for(:new_ui).fetch('enabled', false)
        skip('This spec will fail if not using new UI') unless new_ui

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
      it 'updates the ETD and returns json redirect path' do
        patch :update, params: { id: etd, etd: { title: 'New Title' }, request_from_form: 'true' }

        etd.reload
        expect(etd.title).to eq ['New Title']

        redir_path = JSON.parse(response.body)['redirectPath'].split('?').first
        expect(redir_path).to eq main_app.hyrax_etd_path(etd).split('?').first
      end
    end
  end

  describe "#update (old UI)" do
    before(:all) do
      new_ui = Rails.application.config_for(:new_ui).fetch('enabled', false)
      skip("These specs should only be run for the old UI") if new_ui
    end

    let(:default_attrs) do
      { depositor: user.user_key,
        title: ['Another great thesis by Frodo'],
        school: ['Emory College'],
        department: ['Art History'] }
    end
    let(:attach_supp_files) { false }

    let(:etd) do
      FactoryBot.build(:etd, default_attrs)
    end

    before do
      workflow_setup.setup
      etd.assign_admin_set

      # Add supplemental files if the test needs them
      if attach_supp_files
        supp_file = File.open("#{fixture_path}/magic_warrior_cat.jpg") { |file| Hyrax::UploadedFile.create(supp_file_attrs.merge(file: file)) }
        attributes_for_actor = { uploaded_files: [supp_file.id] }
      end

      # Create the ETD record
      env = Hyrax::Actors::Environment.new(etd, ::Ability.new(user), attributes_for_actor || {})
      middleware = Hyrax::DefaultMiddlewareStack.build_stack.build(Hyrax::Actors::Terminator.new)
      middleware.create(env)

      # Approver requests changes, so student will be able to edit the ETD
      change_workflow_status(etd, "request_changes", approver)

      etd.reload
    end

    context 'with a new title' do
      it "updates the ETD" do
        expect {
          patch :update, params: { id: etd, etd: { title: 'New Title' } }
        }.to change { Etd.count }.by(0)

        etd.reload
        assert_redirected_to main_app.hyrax_etd_path(etd, locale: 'en')
        expect(etd.title).to eq ['New Title']
      end
    end

    context 'with no pre-existing supplemental files' do
      context 'student checks "no supplemental files" checkbox' do
        before do
          patch :update, params: { id: etd, etd: { title: 'New Title', no_supplemental_files: '1' } }
          etd.reload
        end

        it 'successfully updates the ETD' do
          assert_redirected_to main_app.hyrax_etd_path(etd, locale: 'en')
          expect(etd.title).to eq ['New Title']
        end
      end

      context 'student adds supplemental files' do
        let(:new_attrs) do
          {
            title: 'New Title',
            "no_supplemental_files" => "0",
            "supplemental_file_metadata" =>
              { "0" => { filename: "magic_warrior_cat.jpg",
                         title: "Magic Cat",
                         description: "Cat desc",
                         file_type: "Image" },
                "1" => { filename: "rural_clinics.zip",
                         title: "Rural Clinics",
                         description: "Clinic desc",
                         file_type: "Data" } }
          }
        end

        before do
          Hyrax::UploadedFile.delete_all
          FactoryBot.create(:uploaded_file, id: 15, file: file2, user_id: user.id)
          FactoryBot.create(:uploaded_file, id: 16, file: file3, user_id: user.id)
        end

        it 'adds the new supplemental files' do
          expect {
            patch :update,
                  params: { id: etd,
                            uploaded_files: ["15", "16"],
                            etd: new_attrs }
          }.to change { FileSet.count }.by(2)

          etd.reload
          assert_redirected_to main_app.hyrax_etd_path(etd, locale: 'en')
          expect(etd.title).to eq ['New Title']

          expect(etd.supplemental_files_fs.map(&:title)).to contain_exactly(["Magic Cat"], ["Rural Clinics"])
          expect(etd.supplemental_files_fs.map(&:description)).to contain_exactly(["Cat desc"], ["Clinic desc"])
          expect(etd.supplemental_files_fs.map(&:file_type)).to contain_exactly('Image', 'Data')
        end
      end
    end

    context 'with supplemental files' do
      let(:attach_supp_files) { true }

      context 'student adds another supplemental file' do
        let(:new_attrs) do
          {
            title: 'New Title',
            "no_supplemental_files" => "0",
            "supplemental_file_metadata" =>
              { "1" => { "filename" => "rural_clinics.zip",
                         "title" => "Rural Clinics Shapefile",
                         "description" => "rural clinics in Georgia",
                         "file_type" => "Data" } }
          }
        end

        before do
          Hyrax::UploadedFile.delete_all
          FactoryBot.create(:supplementary_uploaded_file, id: 16, file: file3, user_id: user.id)
        end

        it 'keeps existing files and adds new file' do
          expect {
            patch :update, params: {
              id: etd,
              uploaded_files: ["16"],
              etd: new_attrs }
          }.to change { FileSet.count }.by(1)

          assert_redirected_to main_app.hyrax_etd_path(etd, locale: 'en')
          etd.reload
          expect(etd.title).to eq ['New Title']

          expect(etd.supplemental_files_fs.map(&:title)).to contain_exactly(["supp file title"], ["Rural Clinics Shapefile"])
          expect(etd.supplemental_files_fs.map(&:description)).to contain_exactly(["supp file desc"], ["rural clinics in Georgia"])
          expect(etd.supplemental_files_fs.map(&:file_type)).to contain_exactly('Image', 'Data')
        end
      end

      context 'student checks "no supplemental files" checkbox' do
        let(:new_attrs) do
          {
            title: 'New Title',
            "no_supplemental_files" => "1",
            "supplemental_file_metadata" =>
              { "0" => { filename: "magic_warrior_cat.jpg",
                         title: "Magic Cat",
                         description: "Cat desc",
                         file_type: "Image" } }
          }
        end

        before do
          Hyrax::UploadedFile.delete_all
          FactoryBot.create(:supplementary_uploaded_file, id: 16, file: file3, user_id: user.id)
        end

        # Even though the new_attrs contains 'supplemental_file_metadata' and params contains 'uploaded_files', those fields should get ignored because 'no_supplemental_files' should win.
        it 'deletes the existing supplemental files' do
          expect {
            patch :update, params: {
              id: etd,
              uploaded_files: ["16"],
              etd: new_attrs }
          }.to change { FileSet.count }.by(-1)

          assert_redirected_to main_app.hyrax_etd_path(etd, locale: 'en')
          etd.reload
          expect(etd.title).to eq ['New Title']
          expect(etd.supplemental_files_fs).to eq []
        end
      end
    end

    context 'no committee members' do
      let(:no_committee_members) { true }
      context 'student checks "no committee members" checkbox' do
        let(:new_attrs) do
          {
            "no_committee_members" => "1"
          }
        end
        before do
          etd.committee_members.build
        end
        it 'deletes the existing committee members' do
          expect {
            patch :update, params: {
              id: etd,
              etd: new_attrs }
          }.to change { etd.committee_members_names.count }.by(0)

          assert_redirected_to main_app.hyrax_etd_path(etd, locale: 'en')
          etd.reload
          expect(etd.committee_members).to eq []
          expect(etd.committee_members_names).to eq []
        end
      end
    end
  end

  describe "POST create" do
    before do
      workflow_setup.setup
    end

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

  context "supplemental file metadata for browse everything files" do
    let(:params) do
      eval(File.read("#{fixture_path}/form_submission_params/be_uploaded_pdf_and_supplemental_files.rb")) # rubocop:disable Security/Eval
    end
    let(:original_params) do
      eval(File.read("#{fixture_path}/form_submission_params/be_uploaded_pdf_and_supplemental_files.rb")) # rubocop:disable Security/Eval
    end
    let(:corrected_selected_files) do
      eval(File.read("#{fixture_path}/form_submission_params/corrected_selected_files.rb")) # rubocop:disable Security/Eval
    end

    before do
      # the create action calls this method first, which changes the params so that its selected_files hash is in the structure the rest of the app requires, so we change our test params as well
      selected_files = described_class.new.merge_selected_files_hashes(params)
      params["selected_files"] = selected_files
    end

    it "adjusts the selected_files params from browse-everything" do
      expected_selected_files = corrected_selected_files
      selected_files = described_class.new.merge_selected_files_hashes(original_params)

      expect(selected_files).to eq(expected_selected_files)
    end

    it "applies metadata to a ::Hyrax::UploadedFile object" do
      uploaded_file = Hyrax::UploadedFile.create(browse_everything_url: params["uploaded_files"].first)

      described_class.new.apply_metadata_to_uploaded_file(uploaded_file, params)
      expect(uploaded_file.title).to eq "Great File"
      expect(uploaded_file.description).to eq "Super Great"
      expect(uploaded_file.file_type).to eq "Image"
      expect(uploaded_file.pcdm_use).to eq FileSet::SUPPLEMENTAL
    end

    it "identifies a primary object" do
      uploaded_file = Hyrax::UploadedFile.create(browse_everything_url: params["uploaded_files"].last)
      described_class.new.apply_metadata_to_uploaded_file(uploaded_file, params)
      expect(uploaded_file.pcdm_use).to eq FileSet::PRIMARY
    end
    it "gets the supplemental file metadata for a given filename" do
      filename = "new.pdf"

      metadata = described_class.new.get_supplemental_file_metadata(filename, params)
      expect(metadata["title"]).to eq "Other File"
      expect(metadata["description"]).to eq "Also Great"
      expect(metadata["file_type"]).to eq "Video"
      filename = "batch_edit.png"
      metadata = described_class.new.get_supplemental_file_metadata(filename, params)
      expect(metadata["title"]).to eq "Great File"
      expect(metadata["description"]).to eq "Super Great"
      expect(metadata["file_type"]).to eq "Image"
    end
    it "gets supplemental file metadata for fake filename" do
      metadata = described_class.new.get_supplemental_file_metadata("nil.png", params)
      expect(metadata["title"]).to be_nil
      expect(metadata["description"]).to be_nil
      expect(metadata["file_type"]).to be_nil
    end
    it "creates an UploadedFile object for each entry in the uploaded_files array" do
      described_class.new.apply_file_metadata(params)
      params["uploaded_files"].each do |be_upload_url|
        expect(::Hyrax::UploadedFile.where(browse_everything_url: be_upload_url).first).to be_instance_of ::Hyrax::UploadedFile
      end
    end
    it "gets the filename for a browse everything uploaded file" do
      uploaded_file = Hyrax::UploadedFile.create(browse_everything_url: params["uploaded_files"].first)
      expected_filename = "batch_edit.png"
      filename = described_class.new.get_filename_for_uploaded_file(uploaded_file, params)
      expect(filename).to eq expected_filename
    end
    it "gets the url for a filename" do
      expected_url = params["uploaded_files"].first
      url = described_class.new.get_url_for_filename("batch_edit.png", params)
      expect(url).to eq expected_url
    end
  end
end
