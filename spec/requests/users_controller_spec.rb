# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "/user", type: :request do
  let(:user) { FactoryBot.create(:user) }

  context "logged in but not admin" do
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

  describe "authentication" do
    it "uses Shibboleth/Omniauth in production" do
      allow(Rails.env).to receive(:production?).and_return(true)
      get new_user_session_path
      expect(response).to redirect_to(user_shibboleth_omniauth_authorize_path)
    end

    it "uses Devise/Database in non-production environments" do
      allow(Rails.env).to receive(:production?).and_return(false)
      get new_user_session_path
      expect(response).to be_successful # i.e. we didn't redirect to shibboleth
      expect(response).to render_template 'devise/sessions/new'
    end
  end
end
