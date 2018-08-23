require 'rails_helper'
require 'darlingtonia/spec'

RSpec.describe Importer::MigrationMapper do
  subject(:mapper)          { described_class.new(source_host: source_host) }
  let(:foxml)               { File.read("#{fixture_path}/import/digital_object.xml") }
  let(:metadata)            { 'emory:194fv' }
  let(:author_id)           { 'emory:194h4' }
  let(:author_foxml)        { File.read("#{fixture_path}/import/author_info.xml") }
  let(:file_id)             { 'emory:194j8' }
  let(:file_foxml)          { File.read("#{fixture_path}/import/original_file.xml") }
  let(:original_file_id)    { 'emory:194kd' }
  let(:original_file_foxml) { File.read("#{fixture_path}/import/original_file.xml") }
  let(:source_host)         { 'http://test-repo.library.emory.edu/fedora/objects/' }

  it_behaves_like 'a Darlingtonia::Mapper' do
    let(:expected_fields) do
      [:pid, :title, :embargo_lift_date, :abstract, :committee_chair_attributes,
       :committee_members_attributes, :creator, :date_created, :degree, :degree_awarded,
       :degree_granting_institution, :department, :email, :language, :legacy_id,
       :graduation_year, :keyword, :partnering_agency, :post_graduation_email,
       :research_field, :research_field_id, :school, :subfield,
       :submitting_type, :table_of_contents, :abstract_embargoed,
       :files_embargoed, :toc_embargoed, :visibility]
    end
  end

  before do
    mapper.metadata = metadata

    WebMock.disable_net_connect!(allow_localhost: true)

    stub_request(:get,
                 "#{source_host}#{metadata}#{described_class::EXPORT_REQUEST}")
      .to_return(status: 200, body: foxml)

    stub_request(:get,
                 "#{source_host}#{file_id}#{described_class::EXPORT_REQUEST}")
      .to_return(status: 200, body: file_foxml)

    stub_request(:get,
                 "#{source_host}#{original_file_id}#{described_class::EXPORT_REQUEST}")
      .to_return(status: 200, body: file_foxml)

    stub_request(:get,
                 "#{source_host}#{author_id}#{described_class::EXPORT_REQUEST}")
      .to_return(status: 200, body: author_foxml)
  end

  after { WebMock.allow_net_connect! }

  context 'with empty content' do
    let(:foxml) { '' }

    describe '#title' do
      it 'raises a mods error' do
        expect { mapper.title }.to raise_error(/MODS/)
      end
    end
  end

  describe '#title' do
    it 'is mapped from mods:title' do
      expect(mapper.title)
        .to contain_exactly 'Rules in Un-Ruled Lands: The Origins of ' \
                            "Property Rights in\nPalestinian Refugee Camp " \
                            'Sectors across Lebanon and Jordan'
    end
  end

  describe '#embargo_lift_date' do
    it 'has a lift date' do
      expect(mapper.embargo_lift_date).to eq Date.parse('2011-05-24')
    end
  end

  describe '#toc_embargoed' do
    it { expect(mapper.toc_embargoed).to be_falsey }
  end

  describe '#abstract' do
    it 'is mapped from is mapped from formatted "abstract" XHTML' do
      expect(mapper.abstract).to contain_exactly(/^\<p\>Abstract/)
    end
  end

  describe '#committee_chair_attributes' do
    it 'adds committee chair' do
      expect(mapper.committee_chair_attributes[0][:name])
        .to contain_exactly 'Conner, Richard'
    end
  end

  describe '#committee_members_attributes' do
    it 'adds all committee members' do
      expect(mapper.committee_members_attributes.count).to eq 4
    end
  end

  describe '#creator' do
    it 'is mapped from mods:name/mods:displayForm' do
      expect(mapper.creator).to contain_exactly 'Papa, Moomin'
    end
  end

  describe '#degree' do
    it 'is mapped from etd extension degree name' do
      expect(mapper.degree).to contain_exactly 'PhD'
    end
  end

  describe '#degree_awarded' do
    it 'is the degree date' do
      expect(mapper.degree_awarded).to eq Date.parse('2009-05-31')
    end
  end

  describe '#degree_granting_institution' do
    it 'is hard coded as Emory University' do
      expect(mapper.degree_granting_institution)
        .to eq 'http://id.loc.gov/vocabulary/organizations/geu'
    end
  end

  describe '#department' do
    it 'is mapped from mods affiliation' do
      expect(mapper.department).to contain_exactly 'Political Science'
    end
  end

  describe '#email' do
    it 'is mapped from mads "permanent resident"' do
      expect(mapper.email).to contain_exactly(/.+@example\.com/)
    end
  end

  describe '#post_graduation_email' do
    it 'is just the email' do
      expect(mapper.post_graduation_email).to contain_exactly(*mapper.email)
    end
  end

  describe '#graduation_year' do
    it 'is mapped from mods:originInfo/mods:dateIssued' do
      expect(mapper.graduation_year).to eq '2009'
    end
  end

  describe '#keyword' do
    it 'is mapped from mods:subject keyword' do
      expect(mapper.keyword).to contain_exactly "Property Rights",
                                                "Institutions",
                                                "Middle East",
                                                "Palestinian Refugees"
    end
  end

  describe '#language' do
    it 'has a language' do
      expect(mapper.language).to contain_exactly('English')
    end
  end

  describe '#legacy_id' do
    it 'has the legacy pid and ark' do
      expect(mapper.legacy_id).to contain_exactly(metadata, 'ark:/25593/194fv')
    end
  end

  describe '#partnering_agency' do
    it 'contains the partnering agency name' do
      expect(mapper.partnering_agency).to be_empty
    end
  end

  describe '#research_field_id' do
    it 'is mapped from mods:subject proquestresearchfield' do
      expect(mapper.research_field_id).to contain_exactly '0615'
    end
  end

  describe '#table_of_contents' do
    it 'is mapped from formatted "contents" XHTML' do
      expect(mapper.table_of_contents).to contain_exactly(/^\<p\>Table of Contents/)
    end
  end

  describe '#school' do
    it 'is in the controlled vocabulary' do
      expect(mapper.school).to contain_exactly 'Laney Graduate School'
    end
  end

  describe '#subfield' do
    it 'is mapped from etd:discipline' do
      expect(mapper.subfield).to be_empty
    end
  end

  describe '#submitting_type' do
    it 'is mapped from MODS genre' do
      expect(mapper.submitting_type)
        .to contain_exactly('Dissertation', 'thesis')
    end
  end

  describe '#premis_content' do
    it 'has premis file content' do
      expect(mapper.premis_content).not_to be_empty
    end
  end

  describe '#primary_file' do
    it 'has primary file content' do
      expect(mapper.primary_file.content).not_to be_empty
    end
  end

  describe '#original_file' do
    it 'has an original file' do
      expect(mapper.original_file.content).not_to be_empty
    end
  end

  describe '#original_files' do
    it 'has an original file' do
      expect(mapper.original_files.to_a).not_to be_empty
    end
  end

  describe '#supplementary_files' do
    it 'does not have any supplementary files' do
      expect(mapper.supplementary_files.to_a).to be_empty
    end
  end
end
