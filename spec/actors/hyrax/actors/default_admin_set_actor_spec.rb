libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

RSpec.describe Hyrax::Actors::DefaultAdminSetActor do
  before :all do
    ActiveFedora::Cleaner.clean!
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  let(:next_actor) { double('next actor', create: true) }
  let(:actor) do
    Hyrax::Actors::ActorStack.new(etd, depositor_ability, [described_class])
  end
  let(:depositor) { create(:user) }
  let(:depositor_ability) { ::Ability.new(depositor) }
  let(:etd) { FactoryBot.create(:sample_data, admin_set: nil, school: ["Laney Graduate School"]) }
  let(:admin_set) { FactoryBot.create(:admin_set, title: ["Laney Graduate School"], id: "f1881k888") }

  describe "create" do
    before do
      allow(Hyrax::Actors::Terminator).to receive(:new).and_return(next_actor)
      allow(next_actor).to receive(:create).with(admin_set_id: admin_set.id).and_return(true)
    end

    context "when there is no admin_set assigned" do
      let(:attributes) { { admin_set_id: '' } }
      it "assigns the admin_set and admin_set id" do
        actor.create(attributes)
        expect(next_actor)
          .to have_received(:create)
          .with(have_attributes(attributes: { admin_set_id: admin_set.id }))
      end
    end

    context "when admin_set_id is provided" do
      let(:attributes) { { admin_set_id: admin_set.id } }

      it "keeps the admin_set id" do
        actor.create(attributes)
        expect(next_actor)
          .to have_received(:create)
          .with(have_attributes(attributes: attributes))
      end
    end
  end
end
