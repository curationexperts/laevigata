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

  describe "My Files" do
    context "with valid data" do
      let(:data) do
        { currentTab: "My Files", files: {} }
      end

      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "with invalid data" do
      let(:data) do
        { currentTab: "My Files", files: nil }
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
        expect(parsed_data).to eq('ipe_id' => in_progress_etd.id, "schoolHasChanged" => false)
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
          'creator' => 'A Student',
          "schoolHasChanged" => false
        })
      end
    end

    context 'with updated data' do
      let(:new_data) { { 'title': 'The New Title' } }
      it 'changes the existing data' do
        expect(resulting_data).to eq({
          'title' => 'The New Title',
          "schoolHasChanged" => false
        })
      end
    end

    context 'with a lower new currentStep than the old currentStep' do
      let(:new_data) { { 'currentStep': '0' } }
      let(:old_data) { { 'currentStep': '4' } }
      it 'preserves the highest currentStep' do
        expect(resulting_data).to eq({
          'currentStep' => '4',
          "schoolHasChanged" => false
        })
      end
    end

    context 'with a higher new currentStep than the old currentStep' do
      let(:new_data) { { 'currentStep': '3' } }
      let(:old_data) { { 'currentStep': '1' } }
      it 'preserves the highest currentStep' do
        expect(resulting_data).to eq({
          'currentStep' => '3',
          "schoolHasChanged" => false
        })
      end
    end

    context 'with the same new currentStep as the old currentStep' do
      let(:new_data) { { 'currentStep': '2' } }
      let(:old_data) { { 'currentStep': '2' } }
      it 'preserves the highest currentStep' do
        expect(resulting_data).to eq({
          'currentStep' => '2',
          "schoolHasChanged" => false
        })
      end
    end

    context 'with an old school and a new school' do
      let(:new_data) { { 'school': 'laney' } }
      let(:old_data) { { 'school': 'candler', 'schoolHasChanged': false } }

      it 'sets the schoolHasChanged flag to true' do
        expect(resulting_data).to eq({
          'school' => 'laney',
          'schoolHasChanged' => true
        })
      end
    end

    context 'with a new school but no old school' do
      let(:new_data) { { 'school': 'laney' } }
      let(:old_data) { { 'schoolHasChanged': false } }
      it 'sets the schoolHasChanged flag to false' do
        expect(resulting_data).to eq({
          'school' => 'laney',
          'schoolHasChanged' => false
        })
      end

      context 'with no new school but an old school' do
        let(:new_data) { {} }
        let(:old_data) { { 'schoolHasChanged': false, 'school': 'laney' } }
        it 'sets the schoolHasChanged flag to false' do
          expect(resulting_data).to eq({
            'school' => 'laney',
            'schoolHasChanged' => false
          })
        end
      end
    end

    context 'with updated data (symbol vs string keys)' do
      let(:old_data) { { title: 'The Old Title' } }
      let(:new_data) { { 'title': 'The New Title' } }

      it 'changes the existing data without duplicating data' do
        expect(resulting_data).to eq({
          'title' => 'The New Title',
          "schoolHasChanged" => false
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
            'embargo_type' => 'Files',
            "schoolHasChanged" => false
          })
        end
      end

      context 'with existing no_embargoes and new no_embargoes' do
        let(:old_data) { { no_embargoes: '1' } }
        let(:new_data) { { 'embargo_length': described_class::NO_EMBARGO } }

        it "preserves the no_embargoes and adds the new embargo_length data" do
          expect(resulting_data).to eq({
            'embargo_length' => described_class::NO_EMBARGO,
            'no_embargoes' => '1',
            "schoolHasChanged" => false
          })
        end
      end

      context 'with existing embargoes and new embargo data' do
        let(:old_data) { { 'embargo_length': '1 Year', 'embargo_type': 'files_embargoed' } }
        let(:new_data) { { 'embargo_length': '2 Years', 'embargo_type': 'files_embargoed, toc_embargoed' } }

        it 'sets new embargo length and type and does not set no_embargoes' do
          expect(resulting_data).to eq({
            'embargo_length' => '2 Years',
            'embargo_type' => 'files_embargoed, toc_embargoed',
            "schoolHasChanged" => false
          })
        end
      end

      context 'with existing embargoes and new no embargo data' do
        let(:old_data) { { 'embargo_length': '1 Year', 'embargo_type': 'files_embargoed' } }

        let(:new_data) { { 'embargo_length': described_class::NO_EMBARGO } }

        it 'removes old embargo lengths and types and sets no_embargoes' do
          expect(resulting_data).to eq({
            'embargo_length' => described_class::NO_EMBARGO,
            'no_embargoes' => '1',
            "schoolHasChanged" => false
          })
        end
      end
    end

    context 'with no new data' do
      let(:new_data) { {} }

      it 'keeps the old data' do
        expect(resulting_data).to eq({
          'title' => 'The Old Title',
          "schoolHasChanged" => false
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
        expect(resulting_data).to eq({ "schoolHasChanged" => false })
      end
    end

    context 'with blank values' do
      let(:old_data) do
        { 'title' => 'The Old Title',
          'keyword' => ['old keyword'] }
      end

      let(:new_data) do
        { 'partnering_agency' => ['', 'partner 1'],
          'keyword' => ['', nil],
          'committee_members_attributes' => { "0" => { "name" => ["member 1"] } } }
      end

      it 'removes the blank fields' do
        expect(resulting_data).to eq({
          'title' => 'The Old Title',
          'schoolHasChanged' => false,
          'committee_members_attributes' => { "0" => { "name" => ["member 1"] } },
          'partnering_agency' => ['partner 1'],
          'keyword' => []
        })
      end
    end

    context 'with committee chair, but no committee members' do
      let(:old_data) do
        { 'title' => 'The Old Title',
          'committee_members_attributes' => { "0" => { "name" => ["member 1"] } } }
      end

      let(:new_data) do
        { 'committee_chair_attributes' => { "0" => { "name" => ["chair 1"] } } }
      end

      it 'removes existing committee members' do
        expect(resulting_data).to eq({
          'title' => 'The Old Title',
          'schoolHasChanged' => false,
          'committee_chair_attributes' => { "0" => { "name" => ["chair 1"] } },
          'committee_members_attributes' => []
        })
      end
    end

    context 'with committee chair, and committee members' do
      let(:old_data) do
        { 'title' => 'The Old Title',
          'committee_members_attributes' => { "0" => { "name" => ["old member 1"] } } }
      end

      let(:new_data) do
        { 'committee_chair_attributes' => { "0" => { "name" => ["chair 1"] } },
          'committee_members_attributes' => { "0" => { "name" => ["new member 1"] } } }
      end

      it 'updates the committee members data' do
        expect(resulting_data).to eq({
          'title' => 'The Old Title',
          'schoolHasChanged' => false,
          'committee_chair_attributes' => { "0" => { "name" => ["chair 1"] } },
          'committee_members_attributes' => { "0" => { "name" => ["new member 1"] } }
        })
      end
    end

    context 'with no committee chair, and no committee members' do
      let(:old_data) do
        { 'title' => 'The Old Title',
          'committee_members_attributes' => { "0" => { "name" => ["member 1"] } } }
      end
      let(:new_data) { { 'title' => 'new title' } }

      it 'keeps existing committee members' do
        expect(resulting_data).to eq({
          'title' => 'new title',
          'schoolHasChanged' => false,
          'committee_members_attributes' => { "0" => { "name" => ["member 1"] } }
        })
      end
    end

    context 'with files, but without supplemental_files' do
      let(:old_data) do
        { 'title' => 'The Old Title',
          'supplemental_files' => 'old supp files json data',
          'supplemental_file_metadata' => 'old supp metadata' }
      end

      let(:new_data) do
        { 'files' => 'json data for primary file' }
      end

      it 'deletes existing data for supplemental files' do
        expect(resulting_data).to eq({
          'title' => 'The Old Title',
          'schoolHasChanged' => false,
          'files' => 'json data for primary file',
          'supplemental_files' => nil,
          'supplemental_file_metadata' => nil
        })
      end
    end

    context 'with files and supplemental_files fields' do
      let(:old_data) do
        { 'title' => 'The Old Title',
          'supplemental_files' => 'old supp files json data',
          'supplemental_file_metadata' => 'old supp metadata' }
      end

      let(:new_data) do
        { 'files' => 'json data for primary file',
          'supplemental_files' => 'new supp files json data',
          'supplemental_file_metadata' => 'new supp metadata' }
      end

      it 'updates data for supplemental files' do
        expect(resulting_data).to eq({
          'title' => 'The Old Title',
          'schoolHasChanged' => false,
          'files' => 'json data for primary file',
          'supplemental_files' => 'new supp files json data',
          'supplemental_file_metadata' => 'new supp metadata'
        })
      end
    end

    context 'without files or supplemental_files fields' do
      let(:old_data) do
        { 'title' => 'The Old Title',
          'supplemental_files' => 'old supp files json data',
          'supplemental_file_metadata' => 'old supp metadata' }
      end
      let(:new_data) { { 'title' => 'new title' } }

      it 'keeps existing data for supplemental files' do
        expect(resulting_data).to eq({
          'title' => 'new title',
          'schoolHasChanged' => false,
          'supplemental_files' => 'old supp files json data',
          'supplemental_file_metadata' => 'old supp metadata'
        })
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

    context 'an ETD with files attached' do
      let(:ipe) { described_class.new(etd_id: etd.id) }
      let(:etd) {
        work = FactoryBot.build(:etd, etd_attrs)
        # Attach primary PDF
        work.ordered_members << primary_pdf_fs
        work.representative = primary_pdf_fs
        work.thumbnail = primary_pdf_fs
        # Attach supplemental files
        work.ordered_members << supp_1_fs
        work.ordered_members << supp_2_fs
        work.save!
        work
      }
      let(:etd_attrs) { { title: ['My ETD'] } }

      let(:primary_pdf_path) { File.join(fixture_path, 'joey', 'joey_thesis.pdf') }
      let(:primary_pdf_fs) do
        File.open(primary_pdf_path) do |local_file|
          FactoryBot.create(:primary_file_set, content: local_file, label: 'joey_thesis.pdf')
        end
      end

      let(:supp_1_path) { File.join(fixture_path, 'nasa.jpeg') }
      let(:supp_1_fs) do
        File.open(supp_1_path) do |local_file|
          FactoryBot.create(:supplemental_file_set, content: local_file, label: 'nasa.jpeg', file_type: 'Image', title: ['Supp File 1 Title'], description: ['Supp File 1 Desc'])
        end
      end

      let(:supp_2_path) { File.join(fixture_path, 'magic_warrior_cat.jpg') }
      let(:supp_2_fs) do
        File.open(supp_2_path) do |local_file|
          FactoryBot.create(:supplemental_file_set, content: local_file, label: 'magic_warrior_cat.jpg', file_type: 'Image', title: ['Supp File 2 Title'], description: ['Supp File 2 Desc'])
        end
      end

      it 'includes the file info in the JSON datastore' do
        expect(JSON.parse(refreshed_data['files'])).to eq({
          'id' => primary_pdf_fs.id,
          'name' => 'joey_thesis.pdf',
          'size' => primary_pdf_fs.file_size.first,
          'deleteUrl' => "/concern/file_sets/#{primary_pdf_fs.id}",
          'deleteType' => 'DELETE'
        })

        expect(JSON.parse(refreshed_data['supplemental_files'])).to contain_exactly(
          {
            'id' => supp_1_fs.id,
            'name' => 'nasa.jpeg',
            'size' => supp_1_fs.file_size.first,
            'deleteUrl' => "/concern/file_sets/#{supp_1_fs.id}",
            'deleteType' => 'DELETE'
          },
          {
            'id' => supp_2_fs.id,
            'name' => 'magic_warrior_cat.jpg',
            'size' => supp_2_fs.file_size.first,
            'deleteUrl' => "/concern/file_sets/#{supp_2_fs.id}",
            'deleteType' => 'DELETE'
          }
        )

        expect(refreshed_data['supplemental_file_metadata']).to contain_exactly(
          {
            'filename' => 'nasa.jpeg',
            'title' => ['Supp File 1 Title'],
            'description' => ['Supp File 1 Desc'],
            'file_type' => 'Image'
          },
          {
            'filename' => 'magic_warrior_cat.jpg',
            'title' => ['Supp File 2 Title'],
            'description' => ['Supp File 2 Desc'],
            'file_type' => 'Image'
          }
        )
      end
    end

    context 'with stale data in data store' do
      let(:stale_data) {
        {
        title: 'Stale Title from IPE',
        partnering_agency: ['Stale parter agency'],
        embargo_length: '1000 years',
        department: ['Some'],
        other_copyrights: 'true',
        requires_permissions: 'true',
        patents: 'true',
        research_field: 'Cryptozoology'
        }
      }

      let(:new_data) do
        { 'title' => ['New ETD Title'],
          'degree_awarded' => 'August 23, 2018',
          'embargo_length' => '1000 years',
          'keyword' => ['new keyword'],
          'department' => ['Some'],
          'other_copyrights' => 'true',
          'requires_permissions' => 'true',
          'patents' => 'true',
          'research_field' => ['Cryptozoology'],
          'committee_chair_attributes' => [{ 'name' => ['Morgan'], 'affiliation' => ['Another University'] }, { 'name' => ['Merlin'], 'affiliation' => ['Emory University'] }] }
      end

      let(:etd) { Etd.create!(new_data) }
      let(:ipe) { described_class.new(etd_id: etd.id, data: stale_data.to_json) }

      it 'replaces the stale data with updated data' do
        expect(
          refreshed_data.except('committee_chair_attributes', 'ipe_id', 'etd_id', 'title', 'embargo_type', 'partnering_agency')
          ).to eq new_data.except('committee_chair_attributes', 'title', 'embargo_type', 'partnering_agency')
        expect(refreshed_data['committee_chair_attributes'].to_s).to match(/Another University/)
        expect(refreshed_data['committee_chair_attributes'].to_s).to match(/Merlin/)
        expect(refreshed_data['committee_chair_attributes'].to_s).to match(/Emory University/)
        expect(refreshed_data['committee_chair_attributes'].to_s).to match(/Morgan/)
        # Test for affiliation_type, which we need for the form
        expect(refreshed_data['committee_chair_attributes'].to_s).to match(/Non-Emory/)
        expect(refreshed_data['title']).to eq new_data['title'][0]
        expect(refreshed_data['ipe_id']).to eq ipe.id
        expect(refreshed_data['etd_id']).to eq etd.id
      end
    end
  end
end
