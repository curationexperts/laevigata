require 'rails_helper'

describe Hyrax::Actors::CreateWithRemoteFilesActor do
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
    it 'is not an error' do
      expect { middleware.update(env) }.not_to raise_error
    end

    context 'with a remote file' do
      let(:attributes) do
        { remote_files: [{ url: 'http://example.com/moomin.pdf',
                           file_name: 'moomin.pdf' }] }
      end

      it do
        expect { middleware.update(env) }.not_to raise_error
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
