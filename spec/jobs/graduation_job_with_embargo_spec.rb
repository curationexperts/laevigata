require 'rails_helper'
# For a work with an embargo, the GraduationJob should:
# * set the degree_awarded date
# * publish the work (workflow transition)
# * update the relevant User object to have the post-graduation email address
# * update the embargo release date to the user's graduation date plus
#   their requested embargo length
# * send notifications
describe GraduationJob, :clean, integration: true do
  before(:context) do
    workflow_settings = { superusers_config: "#{fixture_path}/config/emory/superusers.yml",
                          admin_sets_config: "#{fixture_path}/config/emory/candler_admin_sets.yml",
                          log_location:      "/dev/null" }

    setup_args = [workflow_settings[:superusers_config],
                  workflow_settings[:admin_sets_config],
                  workflow_settings[:log_location]]

    WorkflowSetup.new(*setup_args).setup
  end

  context "a student with a requested embargo", :perform_jobs do
    let(:user)       { FactoryBot.create(:user) }
    let(:ability)    { ::Ability.new(user) }
    let(:env)        { Hyrax::Actors::Environment.new(Etd.new, ability, attributes) }
    let(:attributes) do
      {
        title: ['The Adventures of Cottontail Rabbit'],
        depositor: user.user_key,
        post_graduation_email: ['me@after.graduation.com'],
        creator: ['Quest, June'],
        school: ["Candler School of Theology"],
        department: ["Divinity"],
        files_embargoed: true,
        abstract_embargoed: true,
        toc_embargoed: true,
        embargo_length: '6 months',
        uploaded_files: [uploaded_file.id]
      }
    end
    let(:uploaded_file) do
      FactoryBot.create :primary_uploaded_file, user_id: user.id
    end
    let(:six_years_from_today) { Time.zone.today + 6.years }
    let(:open)       { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let(:restricted) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    before do
      allow(Hyrax::Workflow::DegreeAwardedNotification).to receive(:send_notification)
      ActiveJob::Base.queue_adapter.filter = [AttachFilesToWorkJob]
      Hyrax::CurationConcern.actor.create(env)
    end
    it "performs the graduation process" do
      etd = Etd.last
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

      # The ETD should now have a degree_awarded date
      expect(etd.degree_awarded).to eq Time.zone.tomorrow

      # An object must be "published" and "active" to be publicly visible
      expect(etd.to_sipity_entity.workflow_state_name).to eq "published"
      expect(etd.state).to eq Vocab::FedoraResourceStatus.active

      # The User object should now have the post_graduation_email, to be used
      # for sending post-graduation notifications (e.g., for embargo expiration)
      expect(user.reload.email).to eq(etd.post_graduation_email.first)

      # The embargo_release_date of the ETD and any attached files should now
      # equal the user's graduation date plus the requested embargo length
      expect(etd.embargo.embargo_release_date).to eq Time.zone.tomorrow + 6.months
      expect(etd.file_sets.first.embargo.embargo_release_date).to eq Time.zone.tomorrow + 6.months

      # Attached files should be restricted during the embargo period
      expect(etd.file_sets.first).to have_attributes visibility: restricted

      # The `embargo_length` does not change. It would better be called
      # 'requested_embargo_length'
      expect(etd.embargo_length).to eq "6 months"

      # Notifications have been sent that the degree was awarded and the ETD was published
      expect(Hyrax::Workflow::DegreeAwardedNotification).to have_received(:send_notification)
    end
  end
end
