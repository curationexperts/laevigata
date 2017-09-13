require 'rails_helper'

RSpec.describe InputSanitizer do
  let(:params) do
    eval(File.read("#{fixture_path}/form_submission_params/office_document_bug.rb")) # rubocop:disable Security/Eval
  end
  it "sanitizes msword input" do
    msword_abstract = params["etd"]["abstract"]
    sanitized_abstract = described_class.sanitize(msword_abstract)
    expect(sanitized_abstract).not_to match(/WordDocument/)
    expect(sanitized_abstract).to match(/Lorem Ipsum is simply dummy text of the printing and typesetting industry./)
  end
  it "leaves tinymce formatting in place" do
    tiny_mce_output = File.read("#{fixture_path}/proquest/tinymce_output.txt")
    sanitized_tiny_mce_output = described_class.sanitize(tiny_mce_output)
    expect(sanitized_tiny_mce_output).to match(/Open Sans/)
    # This is a more thorough test, but difficult to get an exact match
    # expect(sanitized_tiny_mce_output).to eq tiny_mce_output
  end
end
