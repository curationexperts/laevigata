libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

describe Hyrax::UploadsController do
  let(:user) { create(:user) }
  describe "#create" do
    let(:file) { fixture_file_upload('miranda/miranda_thesis.pdf') }

    context "when signed in" do
      before do
        sign_in user
      end

      it "creates a primary file" do
        # Don't queue the fetch job for a normal upload
        expect {
          post :create, params: { primary_files: [file], format: 'json' }
        }.not_to have_enqueued_job(::FetchRemoteFileJob)
        expect(response).to be_success
        expect(assigns(:upload)).to be_kind_of Hyrax::UploadedFile
        expect(assigns(:upload)).to be_persisted
        expect(assigns(:upload).user).to eq user
        expect(assigns(:upload).pcdm_use).to eq "primary"
      end

      it "creates a supplementary file" do
        post :create, params: { supplemental_files: [file], format: 'json' }
        expect(response).to be_success
        expect(assigns(:upload)).to be_kind_of Hyrax::UploadedFile
        expect(assigns(:upload)).to be_persisted
        expect(assigns(:upload).user).to eq user
        expect(assigns(:upload).pcdm_use).to eq "supplementary"
      end

      context "with a remote file from Box" do
        before do
          new_ui = Rails.application.config_for(:new_ui).fetch('enabled', false)
          skip("These tests run only when NEW_UI_ENABLED") unless new_ui
        end

        let(:filename) { 'my_remote_file.pdf' }
        let(:remote_url) { "http://example.com/my_remote_file.pdf" }

        it "queues a job to download the remote file" do
          expect {
            post :create, params: { primary_files: [filename], remote_url: remote_url, filename: filename, format: 'json' }
          }.to have_enqueued_job(::FetchRemoteFileJob)

          # This is how the filename is called in hyrax in `app/views/hyrax/uploads/create.json.jbuilder`.
          expect(assigns(:upload).file.file.filename).to eq filename
        end
      end
    end
  end
end
