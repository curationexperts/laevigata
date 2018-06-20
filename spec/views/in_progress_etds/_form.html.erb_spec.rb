require 'rails_helper'

RSpec.describe 'in_progress_etds/_form.html.erb', type: :view do
  let(:in_progress_etd) { FactoryBot.create(:in_progress_etd) }
  let(:inputs) { Hyrax::EtdForm.terms }
  before do
    assign(:in_progress_etd, in_progress_etd)
    render
  end

  it 'contains inputs for each of the Etd terms' do
    inputs.each do |term|
      expect(rendered).to have_content(term)
    end
  end
end
