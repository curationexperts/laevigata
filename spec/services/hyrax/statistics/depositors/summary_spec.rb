require 'rails_helper'

RSpec.describe Hyrax::Statistics::Depositors::Summary do
  let(:user) { FactoryBot.create(:user) }
  let(:etd) { FactoryBot.create(:sample_data, depositor: user.user_key, school: ["Candler School of Theology"]) }
  it "does not raise an exception when a user has been deleted" do
    expect(etd.depositor).to eq(user.user_key)
    user.ppid = "changed"
    user.save
    expect { described_class.new(nil, nil).depositors }.not_to raise_exception
  end
end
