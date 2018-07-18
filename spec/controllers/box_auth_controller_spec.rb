require 'rails_helper'

RSpec.describe BoxAuthController, type: :controller do
  describe "GET auth" do
    it 'has an auth method' do
      expect(response.status).to eq(200)
    end
  end
end
