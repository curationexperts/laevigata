require 'rails_helper'

RSpec.describe "registrar_feeds/show", type: :view do
  before do
    @registrar_feed = assign(:registrar_feed, FactoryBot.create(:registrar_feed))
  end

  it "displays the status" do
    render
    expect(rendered).to match(/initialized/)
  end
end
