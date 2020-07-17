require 'rails_helper'
describe GraduationJob, integration: true do
  before(:context) do
    workflow_settings = { superusers_config: "#{fixture_path}/config/emory/superusers.yml",
                          admin_sets_config: "#{fixture_path}/config/emory/candler_admin_sets.yml",
                          log_location:      "/dev/null" }

    setup_args = [workflow_settings[:superusers_config],
                  workflow_settings[:admin_sets_config],
                  workflow_settings[:log_location]]

    WorkflowSetup.new(*setup_args).setup
  end

  context "calculating embargo_release_date" do
    it "can interpret a length of '6 months'" do
      e = described_class.embargo_length_to_embargo_release_date(Time.zone.today, "6 months")
      expect(e).to eq Time.zone.today + 6.months
    end
    it "can interpret a length of '3 years'" do
      e = described_class.embargo_length_to_embargo_release_date(Time.zone.today, "3 years")
      expect(e).to eq Time.zone.today + 3.years
    end
    it "can interpret a length of 'None - open access immediately'" do
      e = described_class.embargo_length_to_embargo_release_date(Time.zone.today, "None - open access immediately")
      expect(e).to be <= Time.zone.today
    end
  end

  context "when a student graduates", :perform_jobs do
    let(:attributes) do
      { 'title' => ['The Adventures of Cottontail Rabbit'],
        'post_graduation_email' => ['me@after.graduation.com'],
        'creator' => ['Sneddon, River'],
        'school' => ["Candler School of Theology"],
        'department' => ["Divinity"],
        'embargo_length' => '6 months',
        'files_embargoed' => true,
        'uploaded_files' => [uploaded_file.id] }
    end
    let(:actor)      { Hyrax::CurationConcern.actor }
    let(:ability)    { ::Ability.new(user) }
    let(:etd)        { FactoryBot.build(:etd) }
    let(:terminator) { Hyrax::Actors::Terminator.new }
    let(:user)       { FactoryBot.create(:user) }
    let(:env)        { Hyrax::Actors::Environment.new(etd, ability, attributes) }
    let(:open)       { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let(:restricted) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    let(:uploaded_file) do
      FactoryBot.create :primary_uploaded_file, user_id: user.id
    end
    let(:six_years_from_today) { Time.zone.today + 6.years }
    before do
      allow(Hyrax::Workflow::DegreeAwardedNotification).to receive(:send_notification)
      ActiveJob::Base.queue_adapter.filter = [AttachFilesToWorkJob]
      actor.create(env)
      etd.reload
      expect(etd.degree_awarded).to eq nil
      expect(etd.embargo.embargo_release_date).to eq six_years_from_today
      expect(etd.embargo_length).to eq "6 months"
      expect(etd.reload.file_sets.first.embargo)
        .to have_attributes embargo_release_date: six_years_from_today,
                            visibility_during_embargo: restricted,
                            visibility_after_embargo: open
      expect(etd.file_sets.first)
        .to have_attributes visibility: restricted
      graduation_job = described_class.new
      graduation_job.perform(etd.id, Time.zone.tomorrow)
      etd.reload
    end
    it "records the graduation date" do
      expect(etd.degree_awarded).to eq Time.zone.tomorrow
    end
    it "updates the depositor's email address" do
      expect(user.reload.email).to eq(etd.post_graduation_email.first)
    end
    it "resets the embargo_release_date for the ETD and any attached files" do
      expect(etd.embargo.embargo_release_date).to eq Time.zone.tomorrow + 6.months
      expect(etd.file_sets.first.embargo.embargo_release_date).to eq Time.zone.tomorrow + 6.months
    end
    it "leaves the visibility of the file sets restricted" do
      expect(etd.file_sets.first).to have_attributes visibility: restricted
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
    let(:etd) { FactoryBot.actor_create(:sample_data, school: ["Emory College"], user: depositing_user) }
    let(:depositing_user) { FactoryBot.create(:user) }
    let(:approving_user) { User.where(uid: "ecadmin").first }

    before do
      w.setup

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
