require 'rails_helper'

describe ImportUrlJob do
  let(:admin) { FactoryBot.create(:admin) }
  # The import_url on this fileset is pointed to a box error file. If you need to
  # re-generate the VCR that recorded this HTTP interaction, put the "box_error.html"
  # file from the fixtures directory online somewhere and point to it here.
  let(:etd) { FactoryBot.create(:etd) }
  let(:fileset) { FactoryBot.create(:primary_file_set, import_url: "https://staging-etd.library.emory.edu/downloads/5h73pw048") }

  context 'raise a specific error if file retrieval results in a box error file' do
    before do
      etd.ordered_members << fileset
      etd.save
      fileset.reload
    end
    it 'raises an exception when it encounters a box error message' do
      VCR.use_cassette("box_error", record: :new_episodes) do
        operation = Hyrax::Operation.create!(user: admin, operation_type: "Attach Remote File")
        expect { described_class.perform_now(fileset, operation) }.to raise_exception(ImportUrlJob::RetrievalError)
      end
    end
  end
end
