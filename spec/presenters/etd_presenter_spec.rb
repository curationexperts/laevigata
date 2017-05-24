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
  let(:partnering_agency) { ["Does not apply (no collaborating organization)"] }
  let(:submitting_type) { ["Honors Thesis"] }
  let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let :etd do
    Etd.new(title: title, creator: creator, keyword: keyword, degree: degree, department: department,
            school: school, partnering_agency: partnering_agency, submitting_type: submitting_type, visibility: visibility)
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
  it { is_expected.to delegate_method(:partnering_agency).to(:solr_document) }
  it { is_expected.to delegate_method(:submitting_type).to(:solr_document) }
end
