require 'rails_helper'

auth_hash = OmniAuth::AuthHash.new(
  provider: 'shibboleth',
  uid: 'brian',
  info: {
    email: "brian@beachboys.com",
    name: "Brian Wilson"
  }
)

RSpec.describe User do
  context "shibboleth" do
    let(:user) { described_class.from_omniauth(auth_hash) }
    it "has a uid" do
      expect(user.uid).to eq auth_hash.uid
    end
    it "has a shibboleth provided name" do
      expect(user.display_name).to eq auth_hash.info.name
    end
    it "has a shibboleth provided email" do
      expect(user.email).to eq auth_hash.info.email
    end
  end
  context "signing in twice" do
    it "finds the original account instead of trying to make a new one" do
      expect(described_class.count).to eq 0
      described_class.from_omniauth(auth_hash)
      expect(described_class.count).to eq 1
      described_class.from_omniauth(auth_hash)
      expect(described_class.count).to eq 1
    end
  end
end
