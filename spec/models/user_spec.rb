require 'rails_helper'

auth_hash = OmniAuth::AuthHash.new(
  provider: 'shibboleth',
  uid: "P8806459",
  info: {
    display_name: "Brian Wilson",
    uid: 'brianbboys1967'
  }
)

RSpec.describe User, :clean do
  context "shibboleth" do
    let(:user) { described_class.from_omniauth(auth_hash) }
    it "has a shibboleth provided name" do
      expect(user.display_name).to eq auth_hash.info.display_name
    end
    it "has a shibboleth provided uid" do
      expect(user.uid).to eq auth_hash.info.uid
    end
    it "has a shibboleth provided ppid which is not nil" do
      expect(user.ppid).to eq auth_hash.uid
      expect(user.ppid).not_to eq nil
    end
  end
  context "updating an existing user" do
    let(:user) do
      user = described_class.new(provider: "shibboleth", uid: "fake", ppid: "fake", display_name: nil)
      user.save
      user
    end
    let(:fake_auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'shibboleth',
        uid: "P0001",
        info: {
          display_name: "Boaty McBoatface",
          uid: 'fake'
        }
      )
    end
    it "updates ppid and display_name with values from shibboleth" do
      expect(user.ppid).to eq "fake"
      expect(user.display_name).to eq nil
      described_class.from_omniauth(fake_auth_hash)
      changed_user = described_class.where(uid: "fake").first
      expect(changed_user.ppid).to eq fake_auth_hash.uid
      expect(changed_user.display_name).to eq fake_auth_hash.info.display_name
    end
  end
  context "signing in twice" do
    it "finds the original account instead of trying to make a new one" do
      # create user first time
      expect { described_class.from_omniauth(auth_hash) }
        .to change { described_class.count }
        .by(1)

      # login existing user second time
      expect { described_class.from_omniauth(auth_hash) }
        .not_to change { described_class.count }
    end
  end
  context "invalid shibboleth data" do
    let(:invalid_auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'shibboleth',
        uid: '',
        info: {
          display_name: '',
          uid: ''
        }
      )
    end
    it "does not create a new user" do
      # do not create a new user if uid is blank
      expect { described_class.from_omniauth(invalid_auth_hash) }
        .not_to change { described_class.count }
    end
  end

  describe "#deactivated" do
    let(:user) { FactoryBot.create(:user) }
    it "defaults to false for new users" do
      expect(user.deactivated).to eq false
      expect(user.mailboxer_email(:foo)).not_to be_nil
    end

    it "set to true by User#destroy" do
      expect(user.destroy).to be true
      expect(user.reload.deactivated).to eq true
      expect(user.mailboxer_email(:foo)).to be_nil
    end

    it "disables login when true" do
      expect(user.active_for_authentication?).to be true
      user.deactivated = true
      expect(user.active_for_authentication?).to be false
    end
  end

  describe "#destroy" do
    let(:user) { FactoryBot.create(:user) }

    it "soft deletes the user", :aggregate_failures do
      user.destroy
      deactivated_user = described_class.find(user.id)
      expect(deactivated_user).not_to be nil
      expect(deactivated_user.deactivated?).to be true
      expect(deactivated_user.active_for_authentication?).to be false
    end
  end

  context "user factories" do
    it "makes a user with expected shibboleth fields" do
      user = FactoryBot.create(:user)
      expect(user.ppid).to be_instance_of String
      expect(user.user_key).to eq user.ppid
      expect(user.display_name).to be_instance_of String
      expect(user.uid).to be_instance_of String
    end
    it "makes an admin user" do
      admin = FactoryBot.create(:admin)
      expect(admin.groups.first).to eq "admin"
    end
  end
  it "makes a system user" do
    user_key = "fake_user_key"
    u = ::User.find_or_create_system_user(user_key)
    expect(u.uid).to eq(user_key)
    expect(u.ppid).to eq(user_key)
  end
end
