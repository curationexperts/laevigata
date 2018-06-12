libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'
require 'workflow_setup'

RSpec.describe Hyrax::Workflow::ReviewedNotification, :clean do
  before do
    w = WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null")
    w.setup
  end
  let(:user) { FactoryBot.create(:user) }
  let(:etd) do
    FactoryBot.create(:sample_data, depositor: user.user_key, school: ["Laney Graduate School"])
  end
  let(:ability) { ::Ability.new(user) }
  let(:recipients) do
    { 'to' => [FactoryBot.create(:user), FactoryBot.create(:user)] }
  end
  let(:notification) do
    env = Hyrax::Actors::Environment.new(etd, ability, {})
    Hyrax::CurationConcern.actor.create(env)

    work_global_id = etd.to_global_id.to_s
    entity = Sipity::Entity.where(proxy_for_global_id: work_global_id).first
    described_class.new(entity, '', user, recipients)
  end
  it "can instantiate" do
    expect(notification).to be_instance_of(described_class)
  end
  it "has the full url in the message" do
    expect(notification.message).to match(/http/)
  end
  it "can find depositor" do
    expect(notification.depositor).to be_instance_of(::User)
    expect(notification.depositor.uid).to eq user.uid
  end
  it "can find reviewers" do
    expect(notification.reviewers).to be_instance_of(Array)
    expect(notification.reviewers.pluck(:uid)).to contain_exactly("admin_set_owner", "superman001", "wonderwoman001", "tezprox", "laneyadmin", "laneyadmin2")
  end
  it "sends notifications to the depositor, school reviewers and superusers and no one else" do
    expect(notification.recipients["to"].pluck(:uid)).to contain_exactly("admin_set_owner", "superman001", "wonderwoman001", "tezprox", "laneyadmin", "laneyadmin2", user.uid)
  end
end
