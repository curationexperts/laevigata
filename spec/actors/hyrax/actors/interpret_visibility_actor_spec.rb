libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'
describe Hyrax::Actors::InterpretVisibilityActor do
  let(:user) { create(:user) }
  let(:etd) { FactoryBot.create(:etd) }
  let(:actor) do
    Hyrax::Actors::ActorStack.new(etd,
                                  ::Ability.new(user),
                                  [described_class,
                                   Hyrax::Actors::EtdActor])
  end
  let(:six_years_from_today) { Time.zone.today + 6.years }
  let(:date) { Time.zone.today + 2 }

  describe 'the next actor' do
    let(:root_actor) { double }
    before do
      allow(Hyrax::Actors::Terminator).to receive(:new).and_return(root_actor)
      allow(etd).to receive(:save).and_return(true)
    end

    context 'when visibility is set to open' do
      let(:attributes) do
        { visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
          embargo_length: "6 months" }
      end

      it 'removes embargo_release_date from attributes' do
        allow(root_actor)
          .to receive(:create)
          .with(an_instance_of(Hyrax::Actors::Environment))

        actor.create(attributes)

        expect(root_actor)
          .to have_received(:create)
          .with(an_instance_of(Hyrax::Actors::Environment))
      end
    end
  end

  describe 'create' do
    context 'with embargo' do
      let(:attributes) do
        {
          "title" => ["good fun"],
          "creator" => ["Sneddon, River"],
          "keyword" => [],
          "language" => [""],
          "embargo_length" => "6 months",
          "graduation_date" => [""],
          "school" => ["Candler School of Theology"],
          "department" => ["Divinity"],
          "files_embargoed" => "true",
          "abstract_embargoed" => "false",
          "toc_embargoed" => "false"
        }
      end

      context 'with an embargo length' do
        let(:date) { Time.zone.today + 2 }
        it 'sets a temporary embargo release of date six years from today' do
          actor.create(attributes)
          expect(etd.embargo.embargo_release_date).to eq six_years_from_today
        end
        it "saves the embargo length" do
          actor.create(attributes)
          expect(etd.embargo_length).to eq "6 months"
        end
        it "sets the visibility to open" do
          actor.create(attributes)
          expect(etd.visibility).to eq "open"
        end
      end
    end
  end
  context 'without embargo' do
    let(:attributes) do
      {
        "title" => ["good fun"],
        "creator" => ["Sneddon, River"],
        "keyword" => [],
        "language" => [""],
        "graduation_date" => [""],
        "school" => ["Candler School of Theology"],
        "department" => ["Divinity"],
        "files_embargoed" => "",
        "abstract_embargoed" => "",
        "toc_embargoed" => ""
      }
    end
    context 'without an embargo length' do
      it "does not create an embargo" do
        actor.create(attributes)
        expect(etd.embargo).to eq nil
        expect(etd.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end
    end
  end
end
