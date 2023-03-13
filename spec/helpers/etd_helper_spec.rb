# frozen_string_literal: true
require 'rails_helper'

RSpec.describe EtdHelper, type: :helper do
  let(:etd) { FactoryBot.build(:ateer_etd) }
  let(:form) { double }
  before { helper.instance_variable_set(:@curation_concern, etd) }

  describe "#department_form_opts" do
    example "for new ETDs" do
      allow(etd).to receive(:new_record?).and_return true
      allow(form).to receive(:input)
      helper.school_determined_departments(form)
      expect(form).to have_received(:input).with(:department, hash_including(required: true))
    end
    example "for saved ETDs" do
      allow(etd).to receive(:new_record?).and_return false
      allow(form).to receive(:input)
      helper.school_determined_departments(form)
      expect(form).to have_received(:input).with(:department, hash_including(selected: "Psychology", collection: kind_of(Array)))
    end
  end

  describe "#department_determined_subfields" do
    example "for new ETDs" do
      allow(etd).to receive(:new_record?).and_return true
      allow(form).to receive(:input)
      helper.department_determined_subfields(form)
      expect(form).to have_received(:input).with(:subfield, hash_including(label: "Sub Field"))
    end
    example "for saved ETDs" do
      allow(etd).to receive(:new_record?).and_return false
      allow(form).to receive(:input)
      helper.department_determined_subfields(form)
      expect(form).to have_received(:input).with(:subfield, hash_including(selected: "Clinical Psychology", collection: kind_of(Array)))
    end
  end

  describe "#partnering_agency" do
    example "for new ETDs" do
      allow(etd).to receive(:new_record?).and_return true
      form = double(form)
      allow(form).to receive(:input)
      helper.partnering_agency(form)
      expect(form).to have_received(:input).with(:partnering_agency, hash_including(collection: kind_of(Array)))
    end
    example "for saved ETDs" do
      allow(etd).to receive(:new_record?).and_return false
      etd.partnering_agency = ['CDC']
      form = double(form)
      allow(form).to receive(:input)
      helper.partnering_agency(form)
      expect(form).to have_received(:input).with(:partnering_agency, hash_including(selected: 'CDC'))
    end
  end

  example "#post_graduation_email" do
    allow(Etd).to receive(:find).and_return(etd)
    expect(etd.post_graduation_email).to be_a_kind_of(ActiveTriples::Relation)
    expect(helper.post_graduation_email(etd.id)).to be_a_kind_of(String)
  end
end
