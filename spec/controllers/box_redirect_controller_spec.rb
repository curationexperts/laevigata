require 'rails_helper'

RSpec.describe BoxRedirectController, type: :controller do
  describe "GET redirect_file" do
    it 'has a redirect_file method' do
      expect(response.status).to eq(200)
    end
  end
end
