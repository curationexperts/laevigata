require 'rails_helper'

# Integration tests for the full midddleware stack
# rubocop:disable RSpec/FilePath
describe Hyrax::CurationConcern, :workflow do
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
      let(:open) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

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
          ActiveJob::Base.queue_adapter.filter =
            [IngestJob, AttachFilesToWorkJob]
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

        it 'sets the file embargo' do
          actor.create(env)

          expect(etd.reload.file_sets.first.embargo)
            .to have_attributes embargo_release_date: six_years_from_today,
                                visibility_during_embargo: open,
                                visibility_after_embargo: open
        end
      end
    end
  end
end
# rubocop:enable RSpec/FilePath
