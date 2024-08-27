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

  context "renders department labels" do
    it 'as "Department" by default' do
      etd.school = ['Any School']
      etd.department = ['Some Department']
      render 'hyrax/base/metadata', presenter: etd_presenter
      expect(rendered).to have_css('.etd.attributes th', text: 'Department')
    end

    it 'as "Specialty" for nursing' do
      etd.school = ['Nell Hodgson Woodruff School of Nursing']
      etd.department = ['Any Specialty']
      render 'hyrax/base/metadata', presenter: etd_presenter
      expect(rendered).to have_css('.etd.attributes th', text: 'Specialty')
    end
  end
end
