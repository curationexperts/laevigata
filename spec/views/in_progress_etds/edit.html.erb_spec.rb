require 'rails_helper'

RSpec.describe 'in_progress_etds/edit.html.erb', type: :view do
  let(:user) { FactoryBot.create(:user) }
  before do
    render
  end

  it 'contains a form to edit an in_progress_etd' do
    expect(rendered).to have_selector("form[action='/in_progress_etds']")

    expect(rendered).to have_selector("form[id='new_in_progress_etd']")
  end
end
