require 'rails_helper'

RSpec.describe "_masthead", type: :view do
  before do
    allow(view).to receive(:render).and_call_original
    allow(view).to receive(:render).with('/logo').and_return('logo')
    allow(view).to receive(:render).with('/user_util_links').and_return('util_links')

    # Clear any memoized runtime badge from other tests
    RuntimeInfo.instance_variable_set(:@badge, nil)
  end

  it "displays the current environment (Test)" do
    render
    expect(rendered).to have_selector('div', id: 'environment_badge', text: 'test')
  end
end
