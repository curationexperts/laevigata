require "rails_helper"

RSpec.describe RegistrarFeedsController, type: :routing do
  describe "admin routing" do
    before { allow(UserIsAdmin).to receive(:matches?).and_return(true) }

    it "routes to #index" do
      expect(:get => "/admin/registrar_feeds").to route_to("registrar_feeds#index")
    end

    it "routes to #new" do
      expect(:get => "/admin/registrar_feeds/new").to route_to("registrar_feeds#new")
    end

    it "routes to #show" do
      expect(:get => "/admin/registrar_feeds/1").to route_to("registrar_feeds#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/admin/registrar_feeds").to route_to("registrar_feeds#create")
    end

    it "routes to #destroy" do
      expect(:delete => "/admin/registrar_feeds/1").to route_to("registrar_feeds#destroy", :id => "1")
    end
  end

  # Registrar Feed records should not be user-modifiable after initial upload
  # even by administrators
  describe 'disabled actions' do
    before { allow(UserIsAdmin).to receive(:matches?).and_return(true) }

    it "cannot route to #edit" do
      expect(:get => "/admin/registrar_feeds/1/edit").to route_to("pages#error_404", path: "admin/registrar_feeds/1/edit")
    end

    it "cannot route to #update via PUT" do
      expect(:put => "/admin/registrar_feeds/1").to route_to("pages#error_404", path: "admin/registrar_feeds/1")
    end

    it "cannot route to #update via PATCH" do
      expect(:patch => "/admin/registrar_feeds/1").to route_to("pages#error_404", path: "admin/registrar_feeds/1")
    end
  end

  # Registar Feed data should not be accessible to non-admins
  describe "for non-admins" do
    before { allow(UserIsAdmin).to receive(:matches?).and_return(false) }

    # NOTE: we only need to test one action because all actions are governed by the same routing constraint
    it "restricts #index" do
      expect(:get => "/admin/registrar_feeds").to route_to("pages#error_404", path: "admin/registrar_feeds")
    end
  end
end
