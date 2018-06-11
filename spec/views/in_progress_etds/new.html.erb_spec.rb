require 'rails_helper'

RSpec.describe 'in_progress_etds/new.html.erb', type: :view do
  if Flipflop.new_ui?
    let(:in_progress_etd) { FactoryBot.create(:in_progress_etd) }

    before do
      assign(:in_progress_etd, in_progress_etd)
      render
    end

    it 'contains a form to create a new in_progress_etd' do
      expect(rendered).to have_selector("form[action='/in_progress_etds/1']")
    end
  end
end
