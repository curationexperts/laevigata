require 'rails_helper'

RSpec.describe EtdIndexer do
  let(:indexer) { described_class.new(etd) }
  let(:solr_doc) { indexer.generate_solr_document }

  let(:etd) do
    FactoryBot.build(
      :etd,
      committee_members_attributes: cm_attrs,
      committee_chair_attributes: cc_attrs
    )
  end
  let(:cm_attrs) do
    [{ name: 'Jackson, Henrietta', affiliation: "Starfleet Academy" },
     { name: 'Matsumoto, Yukihiro' }]
  end
  let(:cc_attrs) { [{ name: 'Yurchenko, Alice', affiliation: "Peace University" }] }

  it 'indexes the fields needed for search and faceting' do
    # Index both committee members and chairs for faceting
    expect(solr_doc['committee_names_sim']).to contain_exactly('Jackson, Henrietta, Starfleet Academy', 'Matsumoto, Yukihiro', 'Yurchenko, Alice, Peace University')
  end

  it 'indexes hidden status' do
    etd.hidden = true

    expect(solr_doc['hidden?_bsi']).to be true
  end
end
