# frozen_string_literal: true
require 'rails_helper'

describe EtdPresenter do
  subject { presenter }

  let(:title) { ['China and its Minority Population'] }
  let(:creator) { ['Eun, Dongwon'] }
  let(:keyword) { ['China', 'Minority Population'] }
  let(:degree) { ['MS'] }
  let(:department) { ['Religion'] }
  let(:school) { ['Laney Graduate School'] }
  let(:subfield) { ['Ethics and Society'] }
  let(:partnering_agency) { ["Does not apply (no collaborating organization)"] }
  let(:submitting_type) { ["Honors Thesis"] }
  let(:research_field) { ['Toxicology'] }
  let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let :etd do
    Etd.new(title: title, creator: creator, keyword: keyword, degree: degree, department: department,
            school: school, subfield: subfield, partnering_agency: partnering_agency, submitting_type: submitting_type,
            research_field: research_field, visibility: visibility)
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
  it { is_expected.to delegate_method(:subfield).to(:solr_document) }
  it { is_expected.to delegate_method(:partnering_agency).to(:solr_document) }
  it { is_expected.to delegate_method(:submitting_type).to(:solr_document) }
  it { is_expected.to delegate_method(:research_field).to(:solr_document) }
end
