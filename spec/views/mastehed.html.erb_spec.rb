require 'rails_helper'

RSpec.describe "_masthead", type: :view do
  before do
    allow(view).to receive(:render).and_call_original
    allow(view).to receive(:render).with('/logo').and_return('logo')
    allow(view).to receive(:render).with('/user_util_links').and_return('util_links')
  end

  it "dsiplays the BANNER environment variable" do
    allow(ENV).to receive(:[]).with('BANNER').and_return('banner_text')

    render
    expect(rendered).to have_content('banner_text')
  end
end
