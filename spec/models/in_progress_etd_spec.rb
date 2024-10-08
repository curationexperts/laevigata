require 'rails_helper'

describe InProgressEtd do
  let(:in_progress_etd) { described_class.new(data: data.to_json) }

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
        { currentTab: 'My Advisor',
          committee_chair_attributes: [{ name: ['Professor McGonagall'], affiliation: ['Emory University'] }] }
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
        { currentTab: "My Files", "files": {} }
      end

      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "with a supplemental file and complete metadata" do
      let(:data) do
        { currentTab: "My Files", "files": {}, "supplemental_files": ["file.jpg"], "supplemental_file_metadata": { "0": { "title": "Silent Spring", "description": "Ecology", "file_type": "Image" } } }
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

    context "with a supplemental file but no metadata" do
      let(:data) do
        { currentTab: "My Files", files: {}, supplemental_files: ["file.jpg"] }
      end

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end

    context "with a supplemental file but incomplete metadata" do
      let(:data) do
        { currentTab: "My Files", "files": {}, "supplemental_files": ["file.jpg"], "supplemental_file_metadata": { "0": { "description": "Ecology", "file_type": "Image" } } }
      end

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end

    context "with a supplemental file but empty metadata" do
      let(:data) do
        { currentTab: "My Files", "files": {}, "supplemental_files": ["file.jpg"], "supplemental_file_metadata": { "0": { title: "", "description": "Ecology", "file_type": "Image" } } }
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

    describe 'embargoes' do
      context 'with existing open embargo request and new embargo data' do
        let(:old_data) { { 'embargo_length': 'None - open access immediately' } }
        let(:new_data) { { 'embargo_length': '1 Year', 'embargo_type': VisibilityTranslator::FILES_EMBARGOED } }

        it "updates" do
          expect(resulting_data).to eq({
            'embargo_length' => '1 Year',
            'embargo_type' => 'files_restricted',
            'schoolHasChanged' => false
          })
        end
      end

      context 'with existing no_embargoes and new no_embargoes' do
        let(:old_data) { { 'embargo_length': 'None - open access immediately' } }
        let(:new_data) { { 'embargo_length': described_class::NO_EMBARGO } }

        it "preserves the no_embargoes and adds the new embargo_length data" do
          expect(resulting_data).to eq({
            'embargo_length' => described_class::NO_EMBARGO,
            "schoolHasChanged" => false
          })
        end
      end

      context 'with existing embargoes and new embargo data' do
        let(:old_data) { { 'embargo_length': '1 Year', 'embargo_type': 'files_restricted' } }
        let(:new_data) { { 'embargo_length': '2 Years', 'embargo_type': 'toc_restricted' } }

        it 'sets new embargo length and type' do
          expect(resulting_data).to eq({
            'embargo_length' => '2 Years',
            'embargo_type' => 'toc_restricted',
            "schoolHasChanged" => false
          })
        end
      end

      context 'with existing embargoes and new open access data' do
        let(:old_data) { { 'embargo_length': '1 Year', 'embargo_type': 'value does not change' } }

        let(:new_data) { { 'embargo_length': described_class::NO_EMBARGO } }

        it 'leaves embargo types unmodified' do
          # Other parts of the codebase now have responsibility for setting embargo_type and booleans
          # appropriately when leng => open access
          expect(resulting_data).to include('embargo_length' => described_class::NO_EMBARGO,
                                            'embargo_type' => 'value does not change')
        end
      end

      context 'with existing embargoes and no embargo changes' do
        let(:old_data) { { 'embargo_length': '1 Year', 'embargo_type': 'toc_restricted' } }

        let(:new_data) { { 'abstract': 'Embargo should be unchanged' } }

        it 'leaves embargo length and type unchanged' do
          expect(resulting_data).to eq({
                                         'abstract' => 'Embargo should be unchanged',
                                         'embargo_length' => '1 Year',
                                         'embargo_type' => 'toc_restricted',
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
          'graduation_date' => 'Spring 2021', # Value should be present and not active in config/authorities/graduation_dates.yml
          'degree_awarded' => '2018-08-23',
          'embargo_length' => '200 lustra',
          'files_embargoed' => 'true',
          'toc_embargoed' => 'true',
          'abstract_embargoed' => 'false',
          'keyword' => ['new keyword'],
          'department' => ['Some'],
          'other_copyrights' => 'true',
          'requires_permissions' => 'true',
          'patents' => 'true',
          'research_field' => ['Cryptozoology'],
          'committee_members_attributes' => [{ 'name' => ['Dweck'], 'affiliation' => ['A Famous University'] }, { 'name' => ['Hawking'], 'affiliation' => ['Emory University'] }],
          'committee_chair_attributes' => [{ 'name' => ['Morgan'], 'affiliation' => ['Another University'] }, { 'name' => ['Merlin'], 'affiliation' => ['Emory University'] }] }
      end

      let(:etd) { Etd.create!(new_data) }
      let(:ipe) { described_class.new(etd_id: etd.id, data: stale_data.to_json) }

      it 'replaces the stale data with updated data', :aggregate_failures do
        special_comparisons = ['title', 'degree_awarded', 'files_embargoed', 'toc_embargoed',
                               'abstract_embargoed', 'committee_members_attributes', 'committee_chair_attributes']
        expect(refreshed_data).to include new_data.except(*special_comparisons)
        # Special comparisons for data that's reformatted or otherwise transformed
        expect(refreshed_data['degree_awarded']).to match(new_data['degree_awarded'])
        expect(refreshed_data['committee_members_attributes'])
          .to include(
                hash_including('name' => ['Dweck'], "affiliation" => ['A Famous University']),
                hash_including('name' => ['Hawking'], "affiliation" => ['Emory University'])
              )
        expect(refreshed_data['committee_chair_attributes'])
          .to include(
                hash_including('name' => ['Morgan'], "affiliation" => ['Another University']),
                hash_including('name' => ['Merlin'], "affiliation" => ['Emory University'])
              )
        expect(refreshed_data['title']).to eq new_data['title'][0]
        # Test embargo_type is set correctly from *_embargoed booleans
        expect(refreshed_data['embargo_type']).to eq 'toc_restricted'
        expect(refreshed_data['ipe_id']).to eq ipe.id
        expect(refreshed_data['etd_id']).to eq etd.id
      end
    end
  end
end
