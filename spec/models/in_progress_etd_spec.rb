require 'rails_helper'

describe InProgressEtd do
  let(:in_progress_etd) { described_class.new(data: data.to_json) }
  before(:all) do
    new_ui = Rails.application.config_for(:new_ui).fetch('enabled', false)

    skip("InProgress ETD model tests run only when NEW_UI_ENABLED") unless new_ui
  end

  describe "About Me" do
    context "with valid data" do
      let(:data) do
        { currentTab: "About Me", creator: "Student", graduation_date: "tomorrow", post_graduation_email: "tester@test.com", school: "Laney Graduate School" }
      end

      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "with invalid data" do
      let(:in_progress_etd) { described_class.new(data: { currentTab: "About Me", creator: "Student", graduation_date: "tomorrow", post_graduation_email: "", school: "" }.to_json) }

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end
    context "with missing data" do
      let(:in_progress_etd) { described_class.new(data: { currentTab: "About Me", creator: "Student", post_graduation_email: "" }.to_json) }

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end
  end

  describe "My Program" do
    context "with valid data" do
      let(:data) do
        { currentTab: "My Program", department: "Anthropology", subfield: "Foo", partnering_agency: "DCD", degree: "Non", submitting_type: "Phd" }
      end

      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "with invalid data" do
      let(:data) do
        { currentTab: "My Program", department: "", subfield: "Foo", partnering_agency: "DCD", degree: "Non", submitting_type: "" }
      end

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end
  end

  describe "My Advisor" do
    # TODO: align with committee front end if it changes, which it is likely to
    context "with valid data" do
      let(:data) do
        { currentTab: "My Advisor", "committee_members_attributes": ["member_info"], "committee_chair_attributes": ["chair_info"] }
      end

      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "without valid data" do
      let(:data) do
        { currentTab: "My Advisor" }
      end

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end
  end

  describe "My ETD" do
    context "with valid data" do
      let(:data) do
        { currentTab: "My Etd", "title": "A title", "language": "Francais", "abstract": "<b>Abstract</b>", "table_of_contents": "<i>Chapter One</i>" }
      end

      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "with invalid data" do
      let(:data) do
        { currentTab: "My Etd", "title": "", "language": "", "abstract": "", "table_of_contents": "" }
      end

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end
  end

  # TODO: needs to be adjusted to fit real data structure when tab is built according to wireframe
  describe "Keywords" do
    context "with valid data" do
      let(:data) do
        { currentTab: "Keywords", "keyword": "something", "research_field": ["things"] }
      end

      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "with invalid data" do
      let(:data) do
        { currentTab: "Keywords" }
      end

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end
  end

  # TODO: the validator needs to be adjusted for real embargo front end tab
  describe "Embargo" do
    let(:data) do
      { currentTab: "Embargo" }
    end

    it "is valid" do
      expect(in_progress_etd).to be_valid
    end
  end

  describe '#add_data' do
    let(:in_progress_etd) { described_class.new(data: old_data.to_json) }

    let(:old_data) { { 'title': 'The Old Title' } }
    let(:new_data) { nil }
    let(:resulting_data) { JSON.parse(in_progress_etd.data) } # in-memory data
    let(:return_value) { in_progress_etd.add_data(new_data) }

    before { return_value } # Call the method

    context 'with new data' do
      let(:new_data) { { 'creator': 'A Student' } }

      it 'adds the new data to the old data' do
        expect(resulting_data).to eq({
          'title' => 'The Old Title',
          'creator' => 'A Student'
        })
      end
    end

    context 'with updated data' do
      let(:new_data) { { 'title': 'The New Title' } }
      it 'changes the existing data' do
        expect(resulting_data).to eq({
          'title' => 'The New Title'
        })
      end
    end

    context 'with updated data (symbol vs string keys)' do
      let(:old_data) { { title: 'The Old Title' } }
      let(:new_data) { { 'title': 'The New Title' } }

      it 'changes the existing data without duplicating data' do
        expect(resulting_data).to eq({
          'title' => 'The New Title'
        })
      end
    end

    context 'with no new data' do
      let(:new_data) { {} }

      it 'keeps the old data' do
        expect(resulting_data).to eq({
          'title' => 'The Old Title'
        })
      end
    end

    context 'with nil (but existing data)' do
      let(:new_data) { nil }

      it 'keeps the old data' do
        expect(resulting_data).to eq({
          'title' => 'The Old Title'
        })
      end
    end

    context 'with nil new data (and nil existing data)' do
      let(:in_progress_etd) { described_class.new } # data field is nil
      let(:new_data) { nil }

      it 'returns empty hash' do
        expect(return_value).to eq({})
      end
    end

    context 'with no new data (and no existing data)' do
      let(:in_progress_etd) { described_class.new } # data field is nil
      let(:new_data) { {} }

      it 'returns empty hash' do
        expect(resulting_data).to eq({})
      end
    end
  end
end
