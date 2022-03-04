require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.describe 'Display ETD metadata', :clean, integration: true, type: :system do
  let(:etd) do
    FactoryBot.create(:sample_data_with_copyright_questions,
                      partnering_agency: ["CDC"],
                      school: ["Candler School of Theology"],
                      embargo_length: "6 months",
                      files_embargoed: false,
                      toc_embargoed: nil,
                      abstract_embargoed: '')
  end

  let(:approving_user) { User.where(uid: "candleradmin").first }

  # set up the creation of an approving user
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null") }

  # These are all the fields listed on our show wireframes
  let(:required_fields) do
    [
      "title",
      "creator",
      "graduation_year",
      "abstract",
      "table_of_contents",
      "school",
      "department",
      "degree",
      "submitting_type",
      "language",
      "keyword",
      "committee_chair_name",
      "committee_members_names"
    ]
  end

  let(:primary_pdf_file) { "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf" }
  let(:supplementary_file_one) { "#{::Rails.root}/spec/fixtures/miranda/rural_clinics.zip" }
  let(:supplementary_file_two) { "#{::Rails.root}/spec/fixtures/miranda/image.tif" }

  let(:uploaded_files) do
    [Hyrax::UploadedFile.create(file: File.open(primary_pdf_file), pcdm_use: FileSet::PRIMARY)] +
      secondary_files
  end

  let(:secondary_files) do
    [Hyrax::UploadedFile.create(file:        File.open(supplementary_file_one),
                                pcdm_use:    FileSet::SUPPLEMENTARY,
                                title:       "Rural Clinics in Georgia",
                                description: "GIS shapefile showing rural clinics",
                                file_type:   "Dataset"),
     Hyrax::UploadedFile.create(file:        File.open(supplementary_file_two),
                                pcdm_use:    FileSet::SUPPLEMENTARY,
                                title:       "Photographer",
                                description: "a portrait of the artist",
                                file_type:   "Image")]
  end

  before do
    # There is no fits installed on travis-ci
    allow(CharacterizeJob).to receive(:perform_later)
    # prepare db and create approving_user
    w.setup
    AttachFilesToWorkJob.perform_now(etd, uploaded_files)
  end

  scenario "Show all expected ETD fields" do
    visit("/concern/etds/#{etd.id}")
    required_fields.each do |field|
      value = etd.send(field.to_sym).first
      expect(value).not_to eq nil
      expect(page).to have_content value
    end
    expect(page).to have_content "Rural Clinics in Georgia (GIS shapefile showing rural clinics)"
    expect(page).to have_content "Photographer (a portrait of the artist)"
    expect(page).not_to have_content etd.partnering_agency.first # Partnering agency should only display for Rollins

    expect(page).not_to have_content I18n.t("hyrax.works.requires_permissions_label")
    expect(page).not_to have_content I18n.t("hyrax.works.other_copyrights_label")
    expect(page).not_to have_content I18n.t("hyrax.works.patents_label")

    # User email
    expect(page).not_to have_content("Email: ")
  end

  scenario 'logged in approver sees copyright info' do
    login_as approving_user
    visit("/concern/etds/#{etd.id}")

    # Copyright questions
    expect(page).to have_content I18n.t("hyrax.works.requires_permissions_label")
    expect(page).to have_content I18n.t("hyrax.works.other_copyrights_label")
    expect(page).to have_content I18n.t("hyrax.works.patents_label")

    # User email
    expect(page).to have_content "Email: "

    # Embargo questions
    expect(find('li.attribute-files_embargoed')).to have_content false
    expect(find('li.attribute-toc_embargoed')).to have_content false
    expect(find('li.attribute-abstract_embargoed')).to have_content false
    expect(page).to have_css('.attribute-embargo_length', text: '6 months')
    logout
  end

  scenario "Etds show permission badges but FileSets don't" do
    visit("/concern/etds/#{etd.id}")

    expect(page).to have_css("h1 span")
    expect(page).to have_content("Open Access")

    click_on(etd.title.first.to_s)

    expect(page).not_to have_css("h1 span")
    expect(page).not_to have_content("Open Access")
  end

  scenario "Render PDF file as primary PDF" do
    visit("/concern/etds/#{etd.id}")

    # The primary pdf gets its name changed to the title of the ETD. This test relies on the html structure that the first link in a td.filename is the pdf's title.
    # The Primary pdf fileset table of links appears above the supplemental files table of linked fileset information.

    expect(find("td.attribute.filename a", match: :first)).to have_content etd.title.first.to_s
  end

  context 'with no primary files' do
    let(:uploaded_files) { secondary_files }

    scenario 'Render supplementary files' do
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "Rural Clinics in Georgia (GIS shapefile showing rural clinics)"
      expect(page).to have_content "Photographer (a portrait of the artist)"
    end
  end
end
