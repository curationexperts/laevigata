require 'rails_helper'

describe Hyrax::Actors::LaevigataEmbargo do
  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  let(:user) { create(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:etd) { FactoryBot.create(:etd) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:six_years_from_today) { Time.zone.today + 6.years }
  let(:date) { Time.zone.today + 2 }
  let(:env) { Hyrax::Actors::Environment.new(etd, ability, attributes) }

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
          middleware.create(env)
          expect(etd.embargo.embargo_release_date).to eq six_years_from_today
        end
        it "saves the embargo length" do
          expect(env.attributes[:embargo_length]).to eq "6 months"
          expect(etd.embargo_length).to be_nil
          middleware.create(env)
          expect(env.attributes[:embargo_length]).to be_nil
          expect(etd.embargo_length).to eq "6 months"
        end
        it "sets the visibility to open" do
          middleware.create(env)
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
        middleware.create(env)
        expect(etd.embargo).to eq nil
        expect(etd.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end
    end
  end
end
