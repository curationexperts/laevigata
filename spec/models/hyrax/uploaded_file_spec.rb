libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

describe Hyrax::UploadedFile do
  let(:file1) { File.open(fixture_path + '/joey/joey_thesis.pdf') }
  let(:uploaded_file) { described_class.create(file: file1) }

  context "new file metadata" do
    it "has a pcdm_use" do
      uploaded_file.pcdm_use = FileSet::PRIMARY
      expect(uploaded_file.pcdm_use).to eq FileSet::PRIMARY
    end
    it "has a browse_everything_url" do
      browse_everything_url = "http://example.com/remote/file.pdf"
      uploaded_file.browse_everything_url = browse_everything_url
      expect(uploaded_file.browse_everything_url).to eq browse_everything_url
    end
  end
end
