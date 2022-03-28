# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "/user", type: :request do
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
        get '/admin/users'
        expect(response).to be_successful
        expect(response).to render_template 'admin/users/index'
      end
    end

    describe "deactivate" do
      it "renders a successful response" do
        put activate_path(id: user.id, deactivated: true)
        expect(response).to redirect_to(hyrax.admin_users_path)
        expect(flash[:notice]).to eq "User deactivated"
      end
    end
    describe "activate" do
      it "renders a successful response" do
        put activate_path(id: user.id, deactivated: false)
        expect(response).to redirect_to(hyrax.admin_users_path)
        expect(flash[:notice]).to eq "User reactivated"
      end
    end
  end
end
