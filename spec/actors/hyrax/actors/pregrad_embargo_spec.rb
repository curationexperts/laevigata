require 'rails_helper'

describe Hyrax::Actors::PregradEmbargo do
  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  let(:ability)    { ::Ability.new(FactoryBot.create(:user)) }
  let(:attributes) { {} }
  let(:etd)        { FactoryBot.build(:etd) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:env)        { Hyrax::Actors::Environment.new(etd, ability, attributes) }

  describe '#create' do
    it 'does not apply an embargo' do
      expect { middleware.create(env) }.not_to change { env.attributes }
    end

    context 'with a specific string passed from InProgressEtd' do
      let(:attributes) do
        { 'title' => ['good fun'],
          'creator' => ['Sneddon, River'],
          'school' => ['Emory College'],
          'embargo_length' => InProgressEtd::NO_EMBARGO }
      end

      it 'does not apply an embargo' do
        expect { middleware.create(env) }
          .to change { env.attributes }
          .to attributes.except('embargo_length')
      end
    end

    context 'with a requested embargo' do
      let(:six_years_from_today) { Time.zone.today + 6.years }

      let(:attributes) do
        { 'title' => ['good fun'],
          'creator' => ['Sneddon, River'],
          'school' => ['Emory College'],
          'embargo_length' => '6 months' }
      end

      let(:open) do
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end

      let(:embargo) do
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
      end

      it 'sets pre-graduation embargo attributes' do
        expect { middleware.create(env) }
          .to change { env.attributes }
          .to include embargo_release_date: six_years_from_today.to_s,
                      visibility_during_embargo: open,
                      visibility_after_embargo: open,
                      visibility: embargo
      end
    end
  end

  describe '#update' do
    it 'is not an error' do
      expect { middleware.update(env) }.not_to raise_error
    end
  end

  describe '#destroy' do
    it 'is not an error' do
      expect { middleware.destroy(env) }.not_to raise_error
    end
  end
end
