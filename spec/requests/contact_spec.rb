require 'rails_helper'

RSpec.describe "ContactForm", type: :request do
  describe "GET /contact" do
    it "redirects to the new website" do
      get '/contact'
      expect(response).to redirect_to 'https://libraries.emory.edu/research/open-access-publishing/emory-repositories-policy/etd/contact'
    end
  end
end
