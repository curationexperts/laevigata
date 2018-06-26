# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::EmbargoPresenter do
  subject(:presenter) { described_class.new(SolrDocument.new(attributes)) }
  let(:attributes)    { { 'embargo_release_date_dtsi' => '2015-10-15T00:00:00Z' } }

  describe '#embargo_release_date' do
    it { expect(presenter.embargo_release_date).to eq '15 Oct 2015' }
  end

  describe '#sortable_release_date' do
    it { expect(presenter.sortable_release_date).to eq '2015-10-15' }
  end
end
