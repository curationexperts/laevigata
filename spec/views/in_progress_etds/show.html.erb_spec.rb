require 'rails_helper'

RSpec.describe 'in_progress_etds/show.html.erb', type: :view do
  let(:in_progress_etd) { FactoryBot.create(:in_progress_etd, data: 'Creator = Student') }

  let(:data) { in_progress_etd["data"] }
  before do
    assign(:in_progress_etd, in_progress_etd)
    render
  end

  it 'contains data' do
    expect(rendered).to have_xpath("//input[@value=#{data}]")
  end
end
