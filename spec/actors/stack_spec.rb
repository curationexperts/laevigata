require 'rails_helper'

# Integration tests for the full midddleware stack
describe Hyrax::CurationConcern do
  subject(:actor) { described_class.actor }

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

  let(:ability)    { ::Ability.new(user) }
  let(:etd)        { FactoryBot.build(:etd, visibility: 'restricted') }
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

    it 'sets visibility to open' do
      expect { actor.create(env) }
        .to change { etd.visibility }
        .to Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    context 'with a requested embargo' do
      let(:attributes) do
        { 'title' => ['good fun'],
          'creator' => ['Sneddon, River'],
          'school' => ['Emory College'],
          'embargo_length' => '6 months' }
      end

      let(:many_years_from_today) { Time.current.to_date + Hyrax::Actors::PregradEmbargo::DEFAULT_LENGTH }

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
          .to have_attributes embargo_release_date: many_years_from_today,
                              visibility_during_embargo: open,
                              visibility_after_embargo: open
      end

      it 'clears embargo booleans when embargo_type is "open"', :aggregate_failures do
        etd.files_embargoed = true
        etd.save!
        attributes.merge!({ 'embargo_length' => 'None - open access immediately',
                            'embargo_type' => 'open' })

        actor.create(env)

        expect(etd.embargo_length).to eq 'None - open access immediately'
        expect(etd.embargo_type).to eq VisibilityTranslator::OPEN
        expect(etd.files_embargoed).to eq false
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

        context 'and embargo_type contains files_embargoed' do
          let(:attributes) do
            { 'title' => ['good fun'],
              'creator' => ['Sneddon, River'],
              'school' => ['Emory College'],
              'embargo_length' => '6 months',
              'uploaded_files' => [uploaded_file.id],
              'embargo_type' =>  "all_restricted" }
          end

          it 'sets the file embargo' do
            actor.create(env)

            expect(etd.reload.file_sets.first.embargo)
              .to have_attributes embargo_release_date: many_years_from_today,
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
