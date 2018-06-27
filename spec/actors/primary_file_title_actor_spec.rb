require 'rails_helper'

RSpec.describe PrimaryFileTitleActor do
  let(:old_title) { 'The Original Title' }
  let(:new_title) { 'The Edited Title' }
  let(:update_attrs) { { 'title' => [new_title] } }

  let(:etd) { Etd.create(title: [old_title], members: [fs]) }
  let(:fs) { FileSet.new(title: [old_title], pcdm_use: FileSet::PRIMARY) }

  let(:ability) { ::Ability.new(nil) }
  let(:env) { Hyrax::Actors::Environment.new(etd, ability, update_attrs) }

  let(:terminator) { Hyrax::Actors::Terminator.new }

  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  describe 'Updating an ETD' do
    context 'when the title has changed' do
      it 'also updates the title of the primary FileSet' do
        expect(terminator).to receive(:update).with(env)
        expect(etd.primary_file_fs).to eq [fs]
        middleware.public_send(:update, env)
        expect(fs.reload.title).to eq [new_title]
      end
    end

    context 'when the ETD has no fileset' do
      let(:etd) { Etd.create(title: [old_title]) }

      it 'calls the next actor without updating FileSet' do
        expect(etd.primary_file_fs).to eq []
        expect(terminator).to receive(:update).with(env)
        middleware.public_send(:update, env)
      end
    end

    context 'when the new attributes dont contain title' do
      let(:update_attrs) { { 'description' => ['desc'] } }
      it 'calls the next actor without updating FileSet' do
        expect(terminator).to receive(:update).with(env)
        expect(fs).not_to receive(:save)
        middleware.public_send(:update, env)
      end
    end

    context 'when the new title is the same as the old' do
      let(:update_attrs) { { 'title' => [old_title] } }
      it 'calls the next actor without updating FileSet' do
        expect(terminator).to receive(:update).with(env)
        expect(fs).not_to receive(:save)
        middleware.public_send(:update, env)
      end
    end
  end
end
