require 'rails_helper'

describe Hyrax::Actors::PublicVisibilityActor do
  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  let(:ability)    { ::Ability.new(FactoryBot.create(:user)) }
  let(:attributes) { {} }
  let(:etd)        { FactoryBot.build(:etd, visibility: restricted) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:env)        { Hyrax::Actors::Environment.new(etd, ability, attributes) }

  let(:open) do
    Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  let(:restricted) do
    Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  end

  describe '#create' do
    it 'sets the work visibility to open' do
      expect { middleware.create(env) }
        .to change { env.attributes }
        .to include visibility: open
    end

    context 'when the attributes have a visibility' do
      let(:attributes) { { visibility: restricted } }

      it 'does not change visibility' do
        expect { middleware.create(env) }
          .not_to change { env.attributes }
          .from include visibility: restricted
      end
    end
  end
end
