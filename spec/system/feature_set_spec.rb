require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Feature configuration', type: :system, integration: true do
  context 'via a config file' do
    scenario 'unwanted features are disabled' do
      expect(Flipflop.proxy_deposit?).to eq false
      expect(Flipflop.transfer_works?).to eq false
      expect(Flipflop.batch_upload?).to eq false
      expect(Flipflop.versions_link?).to eq false
    end
  end
end
