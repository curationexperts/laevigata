# frozen_string_literal: true
require 'rails_helper'
require 'workflow_setup'

RSpec.describe 'Display ETD metadata', integration: true, type: :system do
  let(:approving_user) { User.where(uid: "candleradmin").first }

  # alias the etd created in the before :all group
  let(:etd) { @etd }

  # Only run expensive test setup once and use it for all tests since they only read data without making changes
  before :all do
    ActiveFedora::Cleaner.clean!

    @etd = FactoryBot.create(:sample_data_with_copyright_questions,
                        partnering_agency: ["CDC"],
                        school: ["Candler School of Theology"],
                        department: ["Theological Studies"],
                        embargo_length: "6 months",
                        files_embargoed: true,
                        toc_embargoed: nil,
                        abstract_embargoed: '',
                        proquest_submission_date: ['2023-06-16T00:00:00Z'])
    primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
    supplementary_file_two = "#{::Rails.root}/spec/fixtures/miranda/image.tif"

    uploaded_files = [Hyrax::UploadedFile.create(file: File.open(primary_pdf_file), pcdm_use: FileSet::PRIMARY),
                      Hyrax::UploadedFile.create(file:        File.open(supplementary_file_two),
                                  pcdm_use:    FileSet::SUPPLEMENTARY,
                                  title:       "Photographer",
                                  description: "a portrait of the artist",
                                  file_type:   "Image")]

    AttachFilesToWorkJob.perform_now(@etd, uploaded_files)
  end

  scenario "Show all expected ETD fields" do
    required_fields = ["title", "creator", "graduation_date", "abstract", "table_of_contents", "school",
                       "department", "degree", "submitting_type", "language", "keyword",
                       "committee_chair_name", "committee_members_names"]

    visit("/concern/etds/#{etd.id}")
    required_fields.each do |field|
      value = etd.send(field.to_sym).first
      expect(value).not_to eq nil
      expect(page).to have_content value
    end
    expect(page).to have_content "Photographer (a portrait of the artist)"
    expect(page).not_to have_content etd.partnering_agency.first # Partnering agency should only display for Rollins

    # Regular users should not see the copyright questions
    expect(page).not_to have_content I18n.t("hyrax.works.requires_permissions_label")
    expect(page).not_to have_content I18n.t("hyrax.works.other_copyrights_label")
    expect(page).not_to have_content I18n.t("hyrax.works.patents_label")

    # Regular users should not see the Proquest submission date
    expect(page).not_to have_content "Submitted to Proquest"

    # User email
    expect(page).not_to have_content("Email: ")
  end

  scenario 'logged in approver sees copyright info' do
    # Build an EtdPresenter with workflow stubbed out
    # that behaves as if an approver were logged in
    # (in order to avoid the high setup cost of a full workflow)
    doc = SolrDocument.find(etd.id)
    approver = FactoryBot.create(:user)
    presenter = EtdPresenter.new(doc, approver.ability)
    allow(presenter).to receive(:current_ability_is_approver?).and_return true
    allow(EtdPresenter).to receive(:new).and_return presenter

    visit("/concern/etds/#{etd.id}")

    # Copyright questions
    expect(page).to have_content I18n.t("hyrax.works.requires_permissions_label")
    expect(page).to have_content I18n.t("hyrax.works.other_copyrights_label")
    expect(page).to have_content I18n.t("hyrax.works.patents_label")

    # User email
    expect(page).to have_content "Email: "

    # Embargo questions
    expect(find('li.attribute-files_embargoed')).to have_content true
    expect(find('li.attribute-toc_embargoed')).to have_content false
    expect(find('li.attribute-abstract_embargoed')).to have_content false
    expect(page).to have_css('.attribute-embargo_length', text: '6 months')

    # Proquest submission date
    expect(page).to have_content(/Submitted to Proquest\s*16 June 2023/)
  end

  scenario "Etds show permission badges but FileSets don't" do
    visit("/concern/etds/#{etd.id}")

    expect(page).to have_css("h1 span")
    expect(page).to have_content("Open Access")

    click_on(etd.title.first.to_s)

    expect(page).not_to have_css("h1 span")
    expect(page).not_to have_content("Open Access")
  end

  scenario "Render attached files" do
    visit("/concern/etds/#{etd.id}")

    # The primary pdf gets its name changed to the title of the ETD. This test relies on the html structure that the first link in a td.filename is the pdf's title.
    # The Primary pdf fileset table of links appears above the supplemental files table of linked fileset information.

    expect(find("td.attribute.filename a", match: :first)).to have_content etd.title.first.to_s
    expect(page).to have_content "Photographer (a portrait of the artist)"
  end

  describe 'Rollins submissions' do
    let(:etd) {
      FactoryBot.create(:sample_data,
                                  school: ["Rollins School of Public Health"],
                                  department: ["Biostatistics"],
                                  subfield: ["Public Health Informatics"],
                                  partnering_agency: ["CDC", "Hospital or other health care provider"])
    }
    scenario 'display subfield and partnering agencies' do
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content etd.subfield.first
      expect(page).to have_content etd.partnering_agency[0] # can't guarantee order,
      expect(page).to have_content etd.partnering_agency[1] # so test each separately

      expect(page).not_to have_content 'Submitted to Proquest'
    end
  end
end
