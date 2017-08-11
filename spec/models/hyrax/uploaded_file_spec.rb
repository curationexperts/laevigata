libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

describe Hyrax::UploadedFile do
  before do
    # Also added to rails_helper.rb so whenever we create an UploadedFile in
    # test it doesn't actually try to virus check it
    class_double("Clamby").as_stubbed_const
    allow(Clamby).to receive(:virus?).and_return(false)
  end
  let(:file1_path) { "#{fixture_path}/joey/joey_thesis.pdf" }
  context "new file metadata" do
    it "has a pcdm_use" do
      File.open(file1_path) do |f|
        uploaded_file = described_class.create(file: f)
        uploaded_file.pcdm_use = FileSet::PRIMARY
        expect(uploaded_file.pcdm_use).to eq FileSet::PRIMARY
      end
    end
  end

  context "virus scan" do
    let(:virus_file_path) { "#{fixture_path}/virus_checking/virus_check.txt" }
    it "detects viruses and deletes the offending file" do
      allow(Clamby).to receive(:virus?).and_return(true)
      File.open(virus_file_path) do |virus_file|
        uploaded_file = described_class.create(file: virus_file)
        expect(File.exist?(uploaded_file.file.path)).to eq false
      end
    end
    it "keeps going if it does not encounter a virus" do
      File.open(file1_path) do |clean_file|
        uploaded_file = described_class.create(file: clean_file)
        expect(File.exist?(uploaded_file.file.path)).to eq true
      end
    end
  end
end
