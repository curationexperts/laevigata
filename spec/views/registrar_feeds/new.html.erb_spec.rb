require 'rails_helper'

RSpec.describe "registrar_feeds/new", type: :view do
  before do
    assign(:registrar_feed, RegistrarFeed.new(
      status: 1,
      approved_etds: 1,
      graduated_etds: 1,
      published_etds: 1
    ))
  end

  it "renders new registrar_feed form" do
    render

    assert_select "form[action=?][method=?]", registrar_feeds_path, "post" do
      assert_select "input[name=?]", "registrar_feed[status]"

      assert_select "input[name=?]", "registrar_feed[approved_etds]"

      assert_select "input[name=?]", "registrar_feed[graduated_etds]"

      assert_select "input[name=?]", "registrar_feed[published_etds]"
    end
  end
end
