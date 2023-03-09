require 'rails_helper'

RSpec.describe "RegistrarFeeds", type: :request do
  describe "admin functions" do
    let(:admin) { FactoryBot.create(:admin) }
    before { sign_in admin }

    describe "GET /admin/registrar_feeds" do
      it "renders with the dashboard layout" do
        get registrar_feeds_path
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('layouts/hyrax/dashboard')
      end
    end

    describe "GET /admin/registrar_feeds/:id/graduation_records" do
      it "downloads graduation records" do
        feed = FactoryBot.create(:registrar_feed)
        get graduation_records_registrar_feed_path(feed)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include "Biological and Biomedical Sci."
      end
    end

    describe "GET /admin/registrar_feeds/:id/report" do
      it "downloads the report" do
        feed = FactoryBot.create(:completeted_registrar_feed)
        get report_registrar_feed_path(feed)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include "On the Realizability of Polymorphizm"
      end
    end
  end

  describe "restrictions" do
    let(:feed) { FactoryBot.create(:registrar_feed) }
    let(:regular_user) { FactoryBot.create(:user) }

    it "prevents non-admins from accessing registrar data" do
      sign_in regular_user
      get registrar_feeds_path
      expect(response).to have_http_status(:not_found)
    end

    it "prevents non-admins from accessing graduation records" do
      sign_in regular_user
      get graduation_records_registrar_feed_path(feed)
      expect(response).to have_http_status(:not_found)
    end

    it "gives unauthenticated users a 404 page" do
      logout
      get registrar_feeds_path
      expect(response).to have_http_status(:not_found)
    end
  end
end
