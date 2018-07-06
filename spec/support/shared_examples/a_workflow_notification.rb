# frozen_string_literal: true

RSpec.shared_examples 'a workflow notification' do
  include_context 'workflow notification setup'

  it "can instantiate" do
    expect(@notification).to be_instance_of(described_class)
  end
  it "has the full url in the message" do
    expect(@notification.message).to match(/http/)
  end
  it "can find depositor" do
    expect(@notification.depositor).to be_instance_of(::User)
    expect(@notification.depositor.uid).to eq @user.uid
  end
  it "can find approvers" do
    expect(@notification.approvers).to be_instance_of(Array)
    expect(@notification.approvers.pluck(:uid)).to contain_exactly("admin_set_owner", "superman001", "wonderwoman001", "candleradmin", "candleradmin2", "tezprox")
  end
  it "sends notifications to the depositor, school approvers and superusers and no one else" do
    expect(@notification.recipients["to"].pluck(:uid)).to contain_exactly("admin_set_owner", "superman001", "wonderwoman001", "candleradmin", "candleradmin2", "tezprox", @user.uid)
  end
end
