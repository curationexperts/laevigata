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
        post :create, params: { primary_files: [file], format: 'json' }
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
    end
  end
end
