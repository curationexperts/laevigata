require 'rails_helper'

describe Hyrax::Actors::FileVisibilityAttributesActor do
  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  let(:ability)    { ::Ability.new(FactoryBot.create(:user)) }
  let(:attributes) { { visibility: embargo, embargo_release_date: Time.zone.today } }
  let(:etd)        { FactoryBot.build(:etd) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:env)        { Hyrax::Actors::Environment.new(etd, ability, attributes) }

  let(:open) do
    Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  let(:embargo) do
    Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
  end

  let(:restricted) do
    Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  end

  describe '#create' do
    it 'sets the file set visibility to open' do
      expect { middleware.create(env) }
        .to change { env.attributes }
        .to include visibility: open
    end

    context 'when files_embargoed is true' do
      let(:etd) { FactoryBot.build(:etd, files_embargoed: true) }

      it 'sets file set visibility attributes' do
        expect { middleware.create(env) }
          .to change { env.attributes }
          .to include visibility: embargo,
                      visibility_during_embargo: restricted
      end
    end
  end

  describe '#update' do
    let(:etd) { FactoryBot.create(:etd) }

    it 'sets the file set visibility to open' do
      expect { middleware.update(env) }
        .to change { env.attributes }
        .to include visibility: open
    end

    context 'when files_embargoed is true' do
      let(:etd) { FactoryBot.create(:etd, files_embargoed: true) }

      it 'sets file set visibility attributes' do
        expect { middleware.update(env) }
          .to change { env.attributes }
          .to include visibility: embargo,
                      visibility_during_embargo: restricted
      end
    end
  end

  describe '#destroy' do
    it 'is not an error' do
      expect { middleware.destroy(env) }.not_to raise_error
    end
  end
end
