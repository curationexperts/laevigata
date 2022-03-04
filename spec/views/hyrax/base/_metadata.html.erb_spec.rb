require 'rails_helper'
require 'hyrax/presents_attributes'

RSpec.describe 'hyrax/base/_metadata.html.erb', type: :view do
  let(:etd) { FactoryBot.build(:etd, degree_awarded: "Jan 1, 2000") }
  let(:ability) { Ability.new(FactoryBot.build(:user)) }
  let(:etd_presenter) { EtdPresenter.new(SolrDocument.new(etd.to_solr), ability) }
  context "for approvers" do
    before do
      allow(etd_presenter).to receive(:current_ability_is_approver?).and_return(true)
    end
    it 'shows the graduation date to approvers' do
      render 'hyrax/base/metadata', presenter: etd_presenter
      expect(rendered).to have_css('.attribute-degree_awarded', text: '01 January 2000')
    end
  end

  context "for non-approvers" do
    before do
      allow(etd_presenter).to receive(:current_ability_is_approver?).and_return(false)
    end
    it 'shows the graduation date to approvers' do
      render 'hyrax/base/metadata', presenter: etd_presenter
      expect(rendered).to have_no_css('.attribute-degree_awarded')
    end
  end
end
