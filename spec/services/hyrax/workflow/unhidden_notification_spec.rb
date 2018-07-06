libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'
require 'workflow_setup'

RSpec.describe Hyrax::Workflow::UnhiddenNotification, :clean, workflow: { admin_sets_config: 'spec/fixtures/config/emory/candler_admin_sets.yml' } do
  let(:user) { FactoryBot.create(:user) }
  let(:etd) { FactoryBot.create(:sample_data, depositor: user.user_key, school: ["Candler School of Theology"]) }
  let(:ability) { ::Ability.new(user) }
  let(:recipients) do
    { 'to' => [FactoryBot.create(:user), FactoryBot.create(:user)] }
  end
  let(:attributes) { {} }
  let(:env) { Hyrax::Actors::Environment.new(etd, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:middleware) do
    Hyrax::DefaultMiddlewareStack.build_stack.build(terminator)
  end
  let(:notification) do
    middleware.create(env)
    work_global_id = etd.to_global_id.to_s
    entity = Sipity::Entity.where(proxy_for_global_id: work_global_id).first
    described_class.new(entity, '', user, recipients)
  end
  it "acts like a notification" do
    # it "has the full url in the message"
    expect(notification.message).to match(/http/)
    # it "can find depositor"
    expect(notification.depositor).to be_instance_of(::User)
    expect(notification.depositor.uid).to eq user.uid
    # it "can find approvers"
    expect(notification.approvers).to be_instance_of(Array)
    expect(notification.approvers.pluck(:uid)).to contain_exactly("admin_set_owner", "superman001", "wonderwoman001", "tezprox", "candleradmin", "candleradmin2")
    # it "sends notifications to the depositor, school approvers and superusers and no one else"
    expect(notification.recipients["to"].pluck(:uid)).to contain_exactly("admin_set_owner", "superman001", "wonderwoman001", "tezprox", "candleradmin", "candleradmin2", user.uid)
  end
end
