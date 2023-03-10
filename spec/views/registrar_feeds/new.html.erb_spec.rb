require 'rails_helper'

RSpec.describe "registrar_feeds/new", type: :view do
  before do
    assign(:registrar_feed, FactoryBot.build(:registrar_feed))
  end

  it "renders new registrar_feed form", :aggregate_failures do
    render
    expect(rendered).to have_selector("form")
    expect(rendered).to have_field(name: "registrar_feed[graduation_records]")
    expect(rendered).to have_button("commit", type: "submit")
  end
end
