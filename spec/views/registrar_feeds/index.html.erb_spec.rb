require 'rails_helper'

RSpec.describe "registrar_feeds/index", type: :view do
  let(:new_feed)       { FactoryBot.create(:registrar_feed) }
  let(:completed_feed) {
    FactoryBot.create(:completed_registrar_feed,
                                           approved_etds: 7,
                                           graduated_etds: 2,
                                           published_etds: 13)
  }

  before do
    assign(:registrar_feeds, [new_feed, completed_feed])
  end

  it "renders a list of registrar_feeds" do
    render
    expect(rendered).to have_selector 'tr>td', text: "initialized", count: 1
    expect(rendered).to have_selector 'tr>td', text: "completed", count: 1
  end

  it "shows etd counts for completed feeds" do
    render
    expect(rendered).to have_selector 'td.approved_count', text: '7'
    expect(rendered).to have_selector 'td.graduated_count', text: '2'
    expect(rendered).to have_selector 'td.published_count', text: '13'
  end

  it "displays links to download the source data file" do
    render
    expect(rendered).to have_link href: graduation_records_registrar_feed_path(completed_feed)
  end

  it "displays links to download completed job reports" do
    render
    expect(rendered).to have_link href: report_registrar_feed_path(completed_feed)
  end

  it "has a link to upload a new feed" do
    render
    expect(rendered).to have_link href: new_registrar_feed_path
  end
end
