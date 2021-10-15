require 'rails_helper'
# For the supplied ETD and graduation date, the GraduationJob should:
# * set the degree_awarded date
# * publish the work (workflow transition)
# * update the relevant User object to have the post-graduation email address
# * update the embargo release date to the user's graduation date plus their requested embargo length
# * expire the embargo if it has already passed (sometimes happens when graduation is delayed)
# * send notifications
describe GraduationJob, :perform_jobs, integration: true do
  context "standard cases" do
    let(:user)        { FactoryBot.create(:user) }
    let(:ability)     { ::Ability.new(user) }
    let(:for_embargo) { Hyrax::Actors::Environment.new(Etd.new, ability, attributes.merge(embargo)) }
    let(:no_embargo)  { Hyrax::Actors::Environment.new(Etd.new, ability, attributes.merge(open_access)) }
    let(:open)        { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let(:restricted)  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    let(:attributes) {
      Hash[
        title: ['The Adventures of Cottontail Rabbit'],
        depositor: user.user_key,
        post_graduation_email: ['me@after.graduation.com'],
        creator: ['Quest, June'],
        school: ["Candler School of Theology"],
        department: ["Divinity"],
        uploaded_files: [FactoryBot.create(:primary_uploaded_file, user_id: user.id).id]
      ]
    }
    let(:embargo) {
      Hash[
        files_embargoed: true,
        abstract_embargoed: true,
        toc_embargoed: true,
        embargo_length: '6 months'
      ]
    }
    let(:open_access) {
      Hash[
        files_embargoed: false,
        abstract_embargoed: false,
        toc_embargoed: false,
        embargo_length: InProgressEtd::NO_EMBARGO
      ]
    }

    before :all do
      ActiveFedora::Cleaner.clean!
      WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null").setup
    end

    before do
      allow(Hyrax::Workflow::DegreeAwardedNotification).to receive(:send_notification)
      ActiveJob::Base.queue_adapter.filter = [AttachFilesToWorkJob]
    end

    let(:eight_months_ago)     { 8.months.ago.beginning_of_day }
    let(:two_months_ago)       { eight_months_ago + 6.months }
    let(:one_month_ago)        { 1.month.ago.beginning_of_day }
    let(:five_months_from_now) { one_month_ago + 6.months }
    let(:many_years_from_today) { Hyrax::Actors::PregradEmbargo::DEFAULT_LENGTH.from_now.beginning_of_day }

    it "handles ETDs with embargoes expiring in the future", :aggregate_failures do
      # Before the GraduationJob is run
      Hyrax::CurationConcern.actor.create(for_embargo)
      id = for_embargo.curation_concern.id
      etd = Etd.find(id)
      expect(etd.degree_awarded).to eq nil
      expect(etd.embargo.embargo_release_date).to eq many_years_from_today
      expect(etd.embargo_length).to eq "6 months"
      expect(etd.file_sets.first.embargo)
        .to have_attributes embargo_release_date: many_years_from_today,
                            visibility_during_embargo: restricted,
                            visibility_after_embargo: open
      expect(etd.file_sets.first)
        .to have_attributes visibility: restricted
      graduation_job = described_class.new
      graduation_job.perform(etd.id, one_month_ago)
      etd.reload

      # After the GraduationJob is run
      # The ETD should now have a degree_awarded date
      # The degree awarded date will always be in the past
      # because of how the Registrar data is produced
      expect(etd.degree_awarded).to eq one_month_ago

      # An object must be "published" and "active" to be publicly visible
      expect(etd.to_sipity_entity.workflow_state_name).to eq "published"
      expect(etd.state).to eq Vocab::FedoraResourceStatus.active

      # The User object should now have the post_graduation_email, to be used
      # for sending post-graduation notifications (e.g., for embargo expiration)
      expect(user.reload.email).to eq(etd.post_graduation_email.first)

      # The embargo_release_date of the ETD and any attached files should now
      # equal the user's graduation date plus the requested embargo length
      # i.e. one month ago + 6 months = 5 months from now
      expect(etd.embargo.embargo_release_date).to eq five_months_from_now
      expect(etd.file_sets.first.embargo.embargo_release_date).to eq five_months_from_now

      # Attached files should be restricted during the embargo period
      expect(etd.file_sets.first).to have_attributes visibility: restricted

      # The `embargo_length` does not change. It would better be called
      # 'requested_embargo_length'
      expect(etd.embargo_length).to eq "6 months"

      # Notifications have been sent that the degree was awarded and the ETD was published
      expect(Hyrax::Workflow::DegreeAwardedNotification).to have_received(:send_notification)
    end

    it "handles ETDs with embargoes ending before the job run", :aggregate_failures do
      Hyrax::CurationConcern.actor.create(for_embargo)
      etd_id = for_embargo.curation_concern.id
      graduation_job = described_class.new
      graduation_job.perform(etd_id, eight_months_ago)

      etd = Etd.find(etd_id)
      expect(etd.degree_awarded).to eq eight_months_ago
      expect(etd.embargo_length).to eq "6 months"
      expect(etd.to_sipity_entity.workflow_state_name).to eq "published"
      expect(etd.state).to eq Vocab::FedoraResourceStatus.active

      # The embargo should be deactivated (embargo_release_date = nil) and
      # The embargo history should list the embargo_release_date of the expired embargo
      # i.e. 8 months ago + 6 months = 2 months ago
      expect(etd.embargo.embargo_history.last).to include two_months_ago.strftime('%Y-%m-%d')

      # Embargo should be expired and attached files should be visible
      expect(etd.file_sets.first.embargo.embargo_history.last).to include two_months_ago.strftime('%Y-%m-%d')
      expect(etd.file_sets.first).to have_attributes visibility: open
    end

    it "handles ETDs without embargoes", :aggregate_failures do
      Hyrax::CurationConcern.actor.create(no_embargo)
      etd_id = no_embargo.curation_concern.id
      graduation_job = described_class.new
      graduation_job.perform(etd_id, one_month_ago)

      etd = Etd.find(etd_id)
      expect(etd.degree_awarded).to eq one_month_ago
      expect(etd.to_sipity_entity.workflow_state_name).to eq "published"
      expect(etd.state).to eq Vocab::FedoraResourceStatus.active
      expect(etd.file_sets.first).to have_attributes visibility: open
      expect(etd.embargo_length).to eq "None - open access immediately" # i.e. InProgressEtd::NO_EMBARGO

      # The etd should not have an embargo
      expect(etd.embargo).to be_nil
    end

    it "handles ETDs with orphan pre-graduation-embargoes", :aggregate_failures do
      Hyrax::CurationConcern.actor.create(for_embargo)
      # Create an ETD with an embargo requested on submission
      etd_id = for_embargo.curation_concern.id
      # Student changes their mind and switches to open access publication before graduation
      etd = Etd.find(etd_id)
      etd.files_embargoed = false
      etd.abstract_embargoed = false
      etd.toc_embargoed = false
      etd.embargo_length = InProgressEtd::NO_EMBARGO
      etd.save

      # Student graduates and the GraduationJob is run
      graduation_job = described_class.new
      graduation_job.perform(etd_id, one_month_ago)

      # Reload the ETD and make sure it's in a discoverable state
      etd = Etd.find(etd_id)
      expect(etd.degree_awarded).to eq one_month_ago
      expect(etd.to_sipity_entity.workflow_state_name).to eq "published"
      expect(etd.suppressed?).to be_falsey
      expect(etd.state).to eq Vocab::FedoraResourceStatus.active
      expect(etd.file_sets.first).to have_attributes visibility: open
      expect(etd.embargo_length).to eq "None - open access immediately" # i.e. InProgressEtd::NO_EMBARGO

      # The published etd should not have any embargo
      expect(etd.embargo).to be_nil
    end
  end
end
