require 'rails_helper'

describe Hyrax::Actors::CreateWithRemoteFilesActor, :clean do
  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  let(:ability)    { ::Ability.new(user) }
  let(:attributes) { {} }
  let(:etd)        { FactoryBot.build(:etd) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:user)       { FactoryBot.create(:user) }
  let(:env)        { Hyrax::Actors::Environment.new(etd, ability, attributes) }

  describe '#create' do
    it 'is not an error' do
      expect { middleware.create(env) }.not_to raise_error
    end

    context 'with a remote file' do
      let(:attributes) do
        { remote_files: [{ url: import_url, file_name: 'moomin.pdf' },
                         { url: supplement_url, file_name: 'supplement.csv' }] }
      end

      let(:import_url)     { 'http://example.com/moomin.pdf' }
      let(:supplement_url) { 'http://example.com/supplement.csv' }

      before do
        FactoryBot.create :remote_uploaded_file,
                          browse_everything_url: import_url,
                          user_id: user.id,
                          pcdm_use: FileSet::PRIMARY

        FactoryBot.create :remote_uploaded_file,
                          browse_everything_url: supplement_url,
                          user_id: user.id,
                          pcdm_use: FileSet::SUPPLEMENTARY
      end

      it 'attaches a file' do
        expect { middleware.create(env) }
          .to change { etd.file_sets.map(&:import_url) }
          .to contain_exactly(import_url, supplement_url)
      end

      it 'sets pcdm_use' do
        expect { middleware.create(env) }
          .to change { etd.file_sets.map(&:pcdm_use) }
          .to contain_exactly(FileSet::SUPPLEMENTARY, FileSet::PRIMARY)
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
