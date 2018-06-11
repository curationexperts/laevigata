require 'rails_helper'

RSpec.describe 'in_progress_etds/_form.html.erb', type: :view do
  let(:in_progress_etd) { FactoryBot.create(:in_progress_etd) }
  before do
    assign(:in_progress_etd, in_progress_etd)
    render
  end

  it 'the form has a name input' do
    expect(rendered).to have_selector("input#in_progress_etd_name")
  end

  it 'the form has an email input' do
    expect(rendered).to have_selector("input#in_progress_etd_email")
  end

  it 'the form has a graduation_date input' do
    expect(rendered).to have_selector("input#in_progress_etd_graduation_date")
  end

  it 'the form has a submission_type input' do
    expect(rendered).to have_selector("input#in_progress_etd_submission_type")
  end
end
