require 'rails_helper'

RSpec.describe 'in_progress_etds/show.html.erb', type: :view do
  let(:in_progress_etd) { FactoryBot.create(:in_progress_etd) }
  before do
    assign(:in_progress_etd, in_progress_etd)
    render
  end

  it 'contains name' do
    expect(rendered).to have_content('Miranda')
  end

  it 'contains email' do
    expect(rendered).to have_content('miranda@graduated.net')
  end

  it 'contains graduation date' do
    expect(rendered).to have_content('Summer 2020')
  end

  it 'contains submission type' do
    expect(rendered).to have_content("Master's Thesis")
  end
end
