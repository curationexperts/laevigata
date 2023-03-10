# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:time) { '2019-07-17 17:08:08 -0400' }
  let(:est_time) { '07/17/19 05:08 PM' }
  describe '#formatted_date' do
    it 'returns an EST date/time with AM and PM' do
      expect(helper.formatted_date(time: time)). to eq(est_time)
    end
  end
end
