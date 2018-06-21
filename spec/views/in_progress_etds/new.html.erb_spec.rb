require 'rails_helper'

RSpec.describe 'in_progress_etds/new.html.erb', type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:etd) { Etd.new }
  let(:form) { Hyrax::EtdForm.new(etd, ::Ability.new(user), Hyrax::EtdsController) }
  before do
    assign(:form, form)
    assign(:curation_concern, etd)
    render
  end

  it 'contains a form to create a new in_progress_etd' do
    expect(rendered).to have_selector("form[action='/in_progress_etds']")
  end
end
