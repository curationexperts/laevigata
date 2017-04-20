# frozen_string_literal: true
require 'rails_helper'

describe EtdPresenter do
  subject { presenter }

  let(:title) { ['China and its Minority Population'] }
  let(:creator) { ['Eun, Dongwon'] }
  let(:keyword) { ['China', 'Minority Population'] }
  let(:degree) { ['Bachelor of Arts with Honors'] }
  let(:department) { ['Department of Russian and East Asian Languages and Cultures'] }
  let(:school) { ['Emory College of Arts and Sciences'] }
  let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let :etd do
    Etd.new(title: title, creator: creator, keyword: keyword, degree: degree, department: department, school: school, visibility: visibility)
  end

  let(:ability) { Ability.new(user) }

  let(:presenter) do
    described_class.new(SolrDocument.new(etd.to_solr), nil)
  end

  # If the fields require no addition logic for display, you can simply delegate
  # them to the solr document
  it { is_expected.to delegate_method(:degree).to(:solr_document) }
  it { is_expected.to delegate_method(:department).to(:solr_document) }
  it { is_expected.to delegate_method(:school).to(:solr_document) }
end
