require 'rails_helper'

RSpec.describe "RegistrarFeeds", type: :request do
  let(:admin) { FactoryBot.create(:admin) }
  before { sign_in admin }

  describe "GET /registrar_feeds" do
    it "works! (now write some real specs)" do
      get registrar_feeds_path
      expect(response).to have_http_status(:ok)
    end
  end
end
