# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdsController do
  let(:user) { create :user }
  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    sign_in user
  end
  describe "POST create" do
    it "responds to partial data in 'create'" do
      post :create, params: { partial_data: "true", etd: { creator: "Joey", title: "Very Good Thesis" } }
      assert_response :success
      etd = JSON.parse(@response.body)
      assert_equal "Joey", etd['creator']
      assert_equal "Very Good Thesis", etd['title']
    end

    xit "creates an etd from a full data set" do
      post :hyrax_etds, params: { partial_data: false, etd: { creator: "Joey" } }
      assert_redirected_to etd_path(Etd.last)
    end
  end
end
