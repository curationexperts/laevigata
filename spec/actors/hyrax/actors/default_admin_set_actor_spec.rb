libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

RSpec.describe Hyrax::Actors::DefaultAdminSetActor, :clean do
  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end
  let(:depositor) { create(:user) }
  let(:ability) { ::Ability.new(depositor) }
  let(:etd) { FactoryBot.create(:sample_data, admin_set: nil, school: ["Laney Graduate School"]) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:admin_set) { FactoryBot.create(:admin_set, title: ["Laney Graduate School"], id: "f1881k888") }

  describe "create" do
    context "when there is no admin_set assigned" do
      let(:attributes) { {} }
      let(:env) { Hyrax::Actors::Environment.new(etd, ability, attributes) }

      it "assigns the admin_set id" do
        expect(etd.admin_set_id).to be_nil
        admin_set
        middleware.create(env)
        expect(etd.admin_set_id).to eq admin_set.id
      end
    end

    context "when admin_set_id is provided" do
      let(:attributes) { { admin_set_id: admin_set.id } }
      let(:env) { Hyrax::Actors::Environment.new(etd, ability, attributes) }

      it "keeps the admin_set id" do
        expect(etd.admin_set_id).to be_nil
        admin_set
        middleware.create(env)
        expect(etd.admin_set_id).to eq admin_set.id
      end
    end
  end
end
