require 'rails_helper'

describe GraduationJob do
  let(:etd) { FactoryBot.build(:etd) }
  let(:grad_job) { described_class.new }
  context "Proquest submission" do
    before do
      # Stub out GraduationJob methods that are not relevant to ProQuest submission
      # and would require extra setup overhead to work
      allow(grad_job).to receive(:publish_object)
      allow(grad_job).to receive(:send_notifications)
      # Stub Etd.find so we don't have to persist to database,
      # not persisting ETDs to the database saves about 1 second per example
      allow(Etd).to receive(:find).and_return(etd)
    end
    example "for ETDs that meet criteria, calls ProquestJob" do
      allow(ProquestJob).to receive(:perform_later)
      # Stub submission criteria which are tested elsewhere
      allow(grad_job).to receive(:proquest_eligible?).and_return(true)
      grad_job.perform(etd.id, Date.current)
      expect(ProquestJob).to have_received(:perform_later)
    end
    example "for ETDs that don't meet criteria, does not call ProquestJob" do
      allow(ProquestJob).to receive(:perform_later)
      allow(grad_job).to receive(:proquest_eligible?).and_return(false)
      grad_job.perform(etd.id, Date.current)
      expect(ProquestJob).not_to have_received(:perform_later)
    end
    it "sends data from registrar to ProquestJob" do
      # This address should match the address data for "P0000002-UCOL-LIBAS" in the registrar sample data
      grad_record = { "home address 1" => "my place" }
      allow(ProquestJob).to receive(:perform_later)
      allow(grad_job).to receive(:proquest_eligible?).and_return(true)
      grad_job.perform(etd.id, Date.current, grad_record)
      expect(ProquestJob).to have_received(:perform_later).with(etd.id, hash_including(grad_record))
    end
  end
end
