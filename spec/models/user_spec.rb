require 'rails_helper'

RSpec.describe User do
  let(:user) { FactoryGirl.create(:user) }
  it "gives you the user's email when you print the user to the screen" do
    expect(user.to_s).to match(/@example.com/)
  end
end
