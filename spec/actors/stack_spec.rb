require 'rails_helper'

# Integration tests for the full midddleware stack
# rubocop:disable RSpec/FilePath
describe Hyrax::CurationConcern, :workflow do
  subject(:actor) { described_class.actor }

  let(:ability)    { ::Ability.new(FactoryBot.create(:user)) }
  let(:etd)        { FactoryBot.build(:etd) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
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
    end
  end
end
# rubocop:enable RSpec/FilePath
