# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Feature configuration', type: :system, integration: true do
  context 'via a config file' do
    scenario 'unwanted features are disabled' do
      expect(Flipflop.proxy_deposit?).to eq false
      expect(Flipflop.transfer_works?).to eq false
      expect(Flipflop.batch_upload?).to eq false
      expect(Flipflop.versions_and_edit_links?).to eq false
    end
  end
end
