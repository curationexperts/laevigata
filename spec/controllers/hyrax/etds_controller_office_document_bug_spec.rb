# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdsController do
  let(:params) do
    eval(File.read("#{fixture_path}/form_submission_params/office_document_bug.rb")) # rubocop:disable Security/Eval
  end
  context "clean submission" do
    let(:file1) { File.open("#{fixture_path}/miranda/miranda_thesis.pdf") }
    let(:user) { create :user }
    let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/applied_epidemiology_admin_sets.yml", "/dev/null") }
    describe "POST create" do
      it "doesn't crash when it receives massive office document input" do
        allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
        ActiveFedora::Cleaner.clean!
        w.setup
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
        sign_in user
        FactoryBot.create(:uploaded_file, id: 221, file: file1, user_id: user.id, pcdm_use: "primary")
        post :create, params: params
        assert_response :redirect
      end
    end
  end
  context "sanitize input to remove verbose ms word type markup" do
    it "sanitizes abstract" do
      described_class.new.sanitize_input(params)
      expect(params["etd"]["abstract"]).not_to match(/WordDocument/)
    end
    it "sanitizes toc" do
      described_class.new.sanitize_input(params)
      expect(params["etd"]["table_of_contents"]).not_to match(/WordDocument/)
    end
  end
end
