require 'rails_helper'

RSpec.describe 'in_progress_etds/new.html.erb', type: :view do
  let(:user) { FactoryBot.create(:user) }

  before do
    render
  end

  it 'contains a form to create a new in_progress_etd' do
    expect(rendered).to have_selector("form[action='/in_progress_etds']")
  end
end
