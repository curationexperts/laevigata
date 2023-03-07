require "rails_helper"

RSpec.describe RegistrarFeedsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/registrar_feeds").to route_to("registrar_feeds#index")
    end

    it "routes to #new" do
      expect(:get => "/registrar_feeds/new").to route_to("registrar_feeds#new")
    end

    it "routes to #show" do
      expect(:get => "/registrar_feeds/1").to route_to("registrar_feeds#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/registrar_feeds/1/edit").to route_to("registrar_feeds#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/registrar_feeds").to route_to("registrar_feeds#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/registrar_feeds/1").to route_to("registrar_feeds#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/registrar_feeds/1").to route_to("registrar_feeds#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/registrar_feeds/1").to route_to("registrar_feeds#destroy", :id => "1")
    end
  end
end
