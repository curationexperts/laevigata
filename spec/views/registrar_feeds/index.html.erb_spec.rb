require 'rails_helper'

RSpec.describe "registrar_feeds/index", type: :view do
  before(:each) do
    assign(:registrar_feeds, [
      RegistrarFeed.create!(
        :status => 2,
        :approved_etds => 3,
        :graduated_etds => 4,
        :published_etds => 5
      ),
      RegistrarFeed.create!(
        :status => 2,
        :approved_etds => 3,
        :graduated_etds => 4,
        :published_etds => 5
      )
    ])
  end

  it "renders a list of registrar_feeds" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
  end
end
