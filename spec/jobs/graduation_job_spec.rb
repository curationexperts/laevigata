require 'rails_helper'
describe GraduationJob do
  context "calculating embargo_release_date" do
    it "can interpret a length of '6 months'" do
      e = described_class.embargo_length_to_embargo_release_date(Time.zone.today, "6 months")
      expect(e).to eq Time.zone.today + 6.months
    end
    it "can interpret a length of '3 years'" do
      e = described_class.embargo_length_to_embargo_release_date(Time.zone.today, "3 years")
      expect(e).to eq Time.zone.today + 3.years
    end
  end
  context "when a student graduates" do
    let(:etd) { FactoryBot.create(:sample_data, school: ["Candler School of Theology"]) }
    let(:depositing_user) { User.where(ppid: etd.depositor).first }
    let(:six_years_from_today) { Time.zone.today + 6.years }
    before do
      allow(Hyrax::Workflow::DegreeAwardedNotification).to receive(:send_notification)
      # This replicates what InterpretVisibilityActor does
      etd.embargo_length = "6 months"
      etd.apply_embargo(
        six_years_from_today,
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      )
      etd.embargo.save
      etd.save
      expect(etd.degree_awarded).to eq nil
      expect(etd.embargo.embargo_release_date).to eq six_years_from_today
      expect(etd.embargo_length).to eq "6 months"
      described_class.perform_now(etd.id, Time.zone.tomorrow)
      etd.reload
    end
    it "records the graduation date" do
      expect(etd.degree_awarded).to eq Time.zone.tomorrow
    end
    it "resets the embargo_release_date" do
      expect(etd.embargo.embargo_release_date).to eq Time.zone.tomorrow + 6.months
    end
    it "leaves embargo_length intact" do
      expect(etd.embargo_length).to eq "6 months"
    end
    it "sends notifications" do
      expect(Hyrax::Workflow::DegreeAwardedNotification).to have_received(:send_notification)
    end
  end
end
