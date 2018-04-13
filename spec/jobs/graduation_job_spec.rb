require 'rails_helper'
describe GraduationJob do
  context "calculating embargo_release_date", :clean do
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
      graduation_job = described_class.new
      # Don't try to publish the object in this context, we haven't set up workflow here.
      allow(graduation_job).to receive(:publish_object)
      graduation_job.perform(etd.id, Time.zone.tomorrow)
      etd.reload
    end
    it "records the graduation date" do
      expect(etd.degree_awarded).to eq Time.zone.tomorrow
    end
    it "updates the depositor's email address" do
      expect(depositing_user.email).to eq(etd.post_graduation_email.first)
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
  context "workflow transition" do
    let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }
    let(:etd) { FactoryBot.create(:sample_data, school: ["Emory College"]) }
    let(:depositing_user) { User.where(ppid: etd.depositor).first }
    let(:approving_user) { User.where(uid: "ecadmin").first }
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      w.setup
      actor = Hyrax::CurationConcern.actor(etd, ::Ability.new(depositing_user))
      actor.create({})

      # The approving user approves the ETD before graduation
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
      described_class.perform_now(etd.id, Time.zone.today)
    end
    it "transitions the object's workflow to 'graduated' and makes it active (visible)" do
      etd.reload
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "published"
      expect(etd.state).to eq Vocab::FedoraResourceStatus.active
    end
  end
end
