# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "/private", type: :request do
  before :all do
    FileUtils.mkdir_p Rails.root.join("private")
    FileUtils.touch Rails.root.join("private", "report.csv")
  end
  context "logged in but not admin" do
    let(:user) { FactoryBot.create(:user) }
    before { sign_in user }

    it "redirects" do
      put activate_path(id: 1)
      expect(response).to redirect_to blacklight_path
    end
  end
  context "not logged in" do
    it "redirects" do
      put activate_path(id: 1)
      expect(response).to redirect_to new_user_session_path
    end
  end

  context "logged in as admin" do
    let(:user) { FactoryBot.create(:user) }
    let(:admin) { FactoryBot.create(:admin) }
    before { sign_in admin }

    describe "user index" do
      it "renders the links" do
        get '/private/report.csv'
        expect(response).to be_successful
        expect(response.header['Content-type']).to eq "text/csv"
        expect(response.header['Content-Disposition']).to eq "attachment; filename=\"report.csv\""
        expect(response.header['Content-Transfer-Encoding']).to eq "binary"
      end
    end
  end
end
