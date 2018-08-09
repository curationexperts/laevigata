require 'rails_helper'

# Integration tests for the full midddleware stack
describe Hyrax::CurationConcern do
  before(:context) do
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!

    workflow_settings = { superusers_config: "#{fixture_path}/config/emory/superusers.yml",
                          admin_sets_config: "#{fixture_path}/config/emory/ec_admin_sets.yml",
                          log_location:      "/dev/null" }

    setup_args = [workflow_settings[:superusers_config],
                  workflow_settings[:admin_sets_config],
                  workflow_settings[:log_location]]

    WorkflowSetup.new(*setup_args).setup
  end

  after(:context) do
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!
  end

  subject(:actor) { described_class.actor }

  let(:ability)    { ::Ability.new(user) }
  let(:etd)        { FactoryBot.build(:etd) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:user)       { FactoryBot.create(:user) }
  let(:env)        { Hyrax::Actors::Environment.new(etd, ability, attributes) }

  let(:attributes) do
    { 'title' => ['good fun'],
      'creator' => ['Sneddon, River'],
      'school' => ['Emory College'] }
  end

  describe '#create' do
    it 'creates an ETD' do
      expect { actor.create(env) }
        .to change { etd.persisted? }
        .to true
    end

    context 'with a requested embargo' do
      let(:attributes) do
        { 'title' => ['good fun'],
          'creator' => ['Sneddon, River'],
          'school' => ['Emory College'],
          'embargo_length' => '6 months' }
      end

      let(:six_years_from_today) { Time.zone.today + 6.years }

      let(:open)       { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      let(:restricted) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

      it 'sets the embargo length' do
        expect { actor.create(env) }
          .to change { etd.embargo_length }
          .to '6 months'
      end

      it 'applies a pre-graduation embargo' do
        expect { actor.create(env) }
          .to change { etd.embargo }
          .to have_attributes embargo_release_date: six_years_from_today,
                              visibility_during_embargo: open,
                              visibility_after_embargo: open
      end

      context 'with an uploaded file', :perform_jobs do
        before do
          ActiveJob::Base.queue_adapter.filter = [AttachFilesToWorkJob]
        end

        let(:uploaded_file) do
          FactoryBot.create :primary_uploaded_file, user_id: user.id
        end

        let(:attributes) do
          { 'title' => ['good fun'],
            'creator' => ['Sneddon, River'],
            'school' => ['Emory College'],
            'embargo_length' => '6 months',
            'uploaded_files' => [uploaded_file.id] }
        end

        it 'does not embargo file by default' do
          actor.create(env)

          expect(etd.reload.file_sets.first.embargo).to be_nil
          expect(etd.file_sets.first).to have_attributes visibility: open
        end

        context 'and files_embargoed is true' do
          let(:attributes) do
            { 'title' => ['good fun'],
              'creator' => ['Sneddon, River'],
              'school' => ['Emory College'],
              'embargo_length' => '6 months',
              'uploaded_files' => [uploaded_file.id],
              'files_embargoed' => true }
          end

          it 'sets the file embargo' do
            actor.create(env)

            expect(etd.reload.file_sets.first.embargo)
              .to have_attributes embargo_release_date: six_years_from_today,
                                  visibility_during_embargo: restricted,
                                  visibility_after_embargo: open

            expect(etd.file_sets.first)
              .to have_attributes visibility: restricted
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/FilePath
