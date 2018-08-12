require 'rails_helper'
RSpec.describe EmbargoTypeFromAttributes do
  let(:embargo_type) { described_class }

  it 'returns the correct response for files' do
    type = embargo_type.new('true', 'false', 'false')
    expect(type.s).to eq('files_embargoed')
  end

  it 'returns the correct resposne for files and toc' do
    type = embargo_type.new('true', 'true', 'false')
    expect(type.s).to eq('files_embargoed, toc_embargoed')
  end

  it 'returns the correct response for files, toc, and abstract' do
    type = embargo_type.new('true', 'true', 'true')
    expect(type.s).to eq('files_embargoed, toc_embargoed, abstract_embargoed')
  end
end
