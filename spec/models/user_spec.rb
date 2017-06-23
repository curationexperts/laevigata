require 'rails_helper'

auth_hash = OmniAuth::AuthHash.new(
  provider: 'shibboleth',
  uid: 'brianbboys1967',
  info: {
    display_name: "Brian Wilson"
  }
)

RSpec.describe User do
  context "shibboleth" do
    let(:user) { described_class.from_omniauth(auth_hash) }
    it "has a shibboleth provided name" do
      expect(user.display_name).to eq auth_hash.info.display_name
    end
    it "has a shibboleth provided ppid" do
      expect(user.ppid).to eq auth_hash.uid
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
  context "user factories" do
    it "makes a user with expected shibboleth fields" do
      user = FactoryGirl.create(:user)
      expect(user.ppid).to be_instance_of String
      expect(user.user_key).to eq user.ppid
      expect(user.display_name).to be_instance_of String
    end
    it "makes an admin user" do
      admin = FactoryGirl.create(:admin)
      expect(admin.groups.first).to eq "admin"
    end
  end
end
