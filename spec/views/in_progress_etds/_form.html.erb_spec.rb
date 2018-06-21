require 'rails_helper'

RSpec.describe 'in_progress_etds/_form.html.erb', type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:etd) { Etd.new }
  let(:form) { Hyrax::EtdForm.new(etd, ::Ability.new(user), Hyrax::EtdsController) }
  let(:inputs) { Hyrax::EtdForm.terms }
  before do
    assign(:form, form)
    assign(:curation_concern, etd)
    render
  end

  it 'contains inputs for each of the Etd terms' do
    inputs.each do |term|
      expect(rendered).to have_content(term)
    end
  end
end
