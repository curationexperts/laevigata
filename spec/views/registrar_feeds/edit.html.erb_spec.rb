require 'rails_helper'

RSpec.describe "registrar_feeds/edit", type: :view do
  before do
    @registrar_feed = assign(:registrar_feed, FactoryBot.create(:registrar_feed))
  end

  it "renders the edit registrar_feed form" do
    render

    assert_select "form[action=?][method=?]", registrar_feed_path(@registrar_feed), "post" do
      assert_select "input[name=?]", "registrar_feed[status]"

      assert_select "input[name=?]", "registrar_feed[approved_etds]"

      assert_select "input[name=?]", "registrar_feed[graduated_etds]"

      assert_select "input[name=?]", "registrar_feed[published_etds]"
    end
  end
end