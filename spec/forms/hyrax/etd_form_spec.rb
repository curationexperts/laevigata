# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdForm do
  it 'has tests' do
    pending 'replace Vue.js form functionality'
    # 2024-09-12 MHB - The form code is not currently in use since we use Vue.js for ETD submission and editing instead
    # For the time being, I'm removing the tests since they cover code not used in the live application
    expect(File.exist?('app/javascript/App.vue')).to be_falsey
  end
end
