require 'rails_helper'

RSpec.describe "registrar_feeds/show", type: :view do
  before(:each) do
    @registrar_feed = assign(:registrar_feed, RegistrarFeed.create!(
      :status => 2,
      :approved_etds => 3,
      :graduated_etds => 4,
      :published_etds => 5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
  end
end
