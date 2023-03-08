require 'rails_helper'

RSpec.describe "registrar_feeds/index", type: :view do
  before do
    assign(:registrar_feeds, [
             FactoryBot.create(:registrar_feed),
             FactoryBot.create(:completeted_registrar_feed)
           ])
  end

  it "renders a list of registrar_feeds" do
    render
    assert_select "tr>td", text: "initialized", count: 1
    assert_select "tr>td", text: "completed", count: 1
    assert_select "tr>td", text: "2", count: 2
  end
end
