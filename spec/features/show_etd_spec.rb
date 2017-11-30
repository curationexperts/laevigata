require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Display ETD metadata' do
  let(:etd) { FactoryBot.create(:sample_data_with_copyright_questions, partnering_agency: ["CDC"], school: ["Candler School of Theology"]) }
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
      "subfield",
      "keyword",
      "committee_chair_name",
      "committee_members_names",
      "partnering_agency"
    ]
  end
  before do
    uploaded_files = []
    primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
    supplementary_file_one = "#{::Rails.root}/spec/fixtures/miranda/rural_clinics.zip"
    supplementary_file_two = "#{::Rails.root}/spec/fixtures/miranda/image.tif"
    uploaded_files << Hyrax::UploadedFile.create(
      file: File.open(primary_pdf_file),
      pcdm_use: FileSet::PRIMARY
    )
    uploaded_files << Hyrax::UploadedFile.create(
      file: File.open(supplementary_file_one),
      pcdm_use: FileSet::SUPPLEMENTARY,
      title: "Rural Clinics in Georgia",
      description: "GIS shapefile showing rural clinics",
      file_type: "Dataset"
    )
    uploaded_files << Hyrax::UploadedFile.create(
      file: File.open(supplementary_file_two),
      pcdm_use: FileSet::SUPPLEMENTARY,
      title: "Photographer",
      description: "a portrait of the artist",
      file_type: "Image"
    )
    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
    # prepare db and create approving_user
    ActiveFedora::Cleaner.clean!
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

    expect(page).not_to have_content I18n.t("hyrax.works.copyright_question_one_label")
    expect(page).not_to have_content I18n.t("hyrax.works.copyright_question_two_label")
    expect(page).not_to have_content I18n.t("hyrax.works.copyright_question_three_label")
  end

  scenario 'logged in approver sees copyright info' do
    login_as approving_user
    visit("/concern/etds/#{etd.id}")

    expect(page).to have_content I18n.t("hyrax.works.copyright_question_one_label")
    expect(page).to have_content I18n.t("hyrax.works.copyright_question_two_label")
    expect(page).to have_content I18n.t("hyrax.works.copyright_question_three_label")

    logout
  end
end
