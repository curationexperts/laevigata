# frozen_string_literal: true
require 'rails_helper'

RSpec.describe EtdHelper, type: :helper do
  let(:etd) { FactoryBot.build(:sample_data) }

  example "#department_form_opts" do
    helper.instance_variable_set(:@curation_concern, etd)
    form = double(form)
    allow(form).to receive(:input)
    helper.school_determined_departments(form)
    expect(form).to have_received(:input).with(:department, hash_including(input_html: hash_including("data-option-url" => "/authorities/terms/local/:etd_school:")))
  end

  example "#department_determined_subfields" do
    helper.instance_variable_set(:@curation_concern, etd)
    form = double(form)
    allow(form).to receive(:input)
    helper.department_determined_subfields(form)
    expect(form).to have_received(:input).with(:subfield, hash_including(input_html: hash_including("data-option-url" => "/authorities/terms/local/:etd_department:")))
  end

  example "#partnering_agency" do
    helper.instance_variable_set(:@curation_concern, etd)
    form = double(form)
    allow(form).to receive(:input)
    helper.partnering_agency(form)
    expect(form).to have_received(:input).with(:partnering_agency, hash_including(collection: kind_of(Array)))
  end

  example "#post_graduation_email" do
    allow(Etd).to receive(:find).and_return(etd)
    expect(etd.post_graduation_email).to be_a_kind_of(ActiveTriples::Relation)
    expect(helper.post_graduation_email(etd.id)).to be_a_kind_of(String)
  end
end
