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
        { currentTab: "My Program", department: "Anthropology", partnering_agency: "DCD", degree: "Non", submitting_type: "Phd" }
      end

      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "with invalid data" do
      let(:data) do
        { currentTab: "My Program", department: "", partnering_agency: "DCD", degree: "Non", submitting_type: "" }
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

  describe "My Advisor" do
    context "with valid data" do
      let(:data) do
        { currentTab: "My Advisor", "committee_chair_attributes": "[0][affiliation_type]Emory" }
      end
      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "with invalid data" do
      let(:data) do
        { currentTab: "My Advisor" }
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

  describe '#add_id_to_data_store' do
    let(:in_progress_etd) { described_class.new }
    let(:parsed_data) { JSON.parse(in_progress_etd.data) }

    context "a record that has been saved" do
      before do
        in_progress_etd.save!
        in_progress_etd.reload
      end

      it 'has the ID in the data' do
        expect(parsed_data).to eq('ipe_id' => in_progress_etd.id)
      end
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

    context 'with a lower new currentStep than the old currentStep' do
      let(:new_data) { { 'currentStep': '0' } }
      let(:old_data) { { 'currentStep': '4' } }
      it 'preserves the highest currentStep' do
        expect(resulting_data).to eq({
          'currentStep' => '4'
        })
      end
    end

    context 'with a higher new currentStep than the old currentStep' do
      let(:new_data) { { 'currentStep': '3' } }
      let(:old_data) { { 'currentStep': '1' } }
      it 'preserves the highest currentStep' do
        expect(resulting_data).to eq({
          'currentStep' => '3'
        })
      end
    end

    context 'with the same new currentStep as the old currentStep' do
      let(:new_data) { { 'currentStep': '2' } }
      let(:old_data) { { 'currentStep': '2' } }
      it 'preserves the highest currentStep' do
        expect(resulting_data).to eq({
          'currentStep' => '2'
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

    describe 'no embargoes' do
      context 'with existing no_embargoes data and new embargo data' do
        let(:old_data) { { no_embargoes: '1' } }
        let(:new_data) { { 'embargo_length': '1 Year', 'embargo_type': 'Files' } }

        it "removes the old no_embargoes parameter and adds the new embargo lengths and types" do
          expect(resulting_data).to eq({
            'embargo_length' => '1 Year',
            'embargo_type' => 'Files'
          })
        end
      end

      context 'with existing no_embargoes and new no_embargoes' do
        let(:old_data) { { no_embargoes: '1' } }
        let(:new_data) { { 'embargo_length': 'None - open access immediately' } }

        it "preserves the no_embargoes and adds the new embargo_length data" do
          expect(resulting_data).to eq({
            'embargo_length' => 'None - open access immediately',
            'no_embargoes' => '1'
          })
        end
      end

      context 'with existing embargoes and new embargo data' do
        let(:old_data) { { 'embargo_length': '1 Year', 'embargo_type': 'files_embargoed' } }
        let(:new_data) { { 'embargo_length': '2 Years', 'embargo_type': 'files_embargoed, toc_embargoed' } }

        it 'sets new embargo length and type and does not set no_embargoes' do
          expect(resulting_data).to eq({
            'embargo_length' => '2 Years',
            'embargo_type' => 'files_embargoed, toc_embargoed'
          })
        end
      end

      context 'with existing embargoes and new no embargo data' do
        let(:old_data) { { 'embargo_length': '1 Year', 'embargo_type': 'files_embargoed' } }

        let(:new_data) { { 'embargo_length': 'None - open access immediately' } }

        it 'removes old embargo lengths and types and sets no_embargoes' do
          expect(resulting_data).to eq({
            'embargo_length' => 'None - open access immediately',
            'no_embargoes' => '1'
          })
        end
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

  describe '#refresh_from_etd!' do
    let(:refreshed_data) { JSON.parse(ipe.data) }
    before { ipe.refresh_from_etd! }

    context 'without an associated Etd record' do
      let(:ipe) { described_class.new(etd_id: nil, data: data.to_json) }
      let(:data) { { 'title' => ['Title from IPE'] } }

      it 'keeps the old data' do
        expect(refreshed_data).to eq data
      end
    end

    context 'with stale data in data store' do
      let(:stale_data) { { title: ['Stale Title from IPE'], partnering_agency: ['Stale parter agency'] } }

      let(:new_data) do
        { 'title' => ['New ETD Title'],
          'keyword' => ['new keyword'],
          'committee_members_attributes' => [{ 'name' => ['Arthur'], 'affiliation' => ['Emory University'] }],
          'committee_chair_attributes' => [{ 'name' => ['Morgan'], 'affiliation' => ['Another University'] }, { 'name' => ['Merlin'], 'affiliation' => ['Emory University'] }] }
      end

      let(:etd) { Etd.create!(new_data) }
      let(:ipe) { described_class.new(etd_id: etd.id, data: stale_data.to_json) }

      it 'replaces the stale data with updated data' do
        expect(refreshed_data.except('committee_chair_attributes', 'ipe_id', 'etd_id')).to eq new_data.except('committee_chair_attributes')
        expect(refreshed_data['committee_chair_attributes']).to contain_exactly *new_data['committee_chair_attributes']
        expect(refreshed_data['ipe_id']).to eq ipe.id
        expect(refreshed_data['etd_id']).to eq etd.id
      end
    end
  end
end
