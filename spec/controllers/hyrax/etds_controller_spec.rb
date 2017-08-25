# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdsController do
  let(:user) { create :user }
  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    sign_in user
  end
  describe "POST create" do
    it "responds to partial data in 'create'" do
      post :create, params: { partial_data: "true", etd: { creator: "Joey", title: "Very Good Thesis" } }
      assert_response :success
      etd = JSON.parse(@response.body)
      assert_equal "Joey", etd['creator']
      assert_equal "Very Good Thesis", etd['title']
    end

    xit "creates an etd from a full data set" do
      post :hyrax_etds, params: { partial_data: false, etd: { creator: "Joey" } }
      assert_redirected_to etd_path(Etd.last)
    end
  end
  describe "supplemental file metadata" do
    let(:params) do
      {
        "etd" => {
          "title" => "My Title",
          "no_supplemental_files" => "0",
          "supplemental_file_metadata" => {
            "0" => {
              "filename" => "magic_warrior_cat.jpg",
              "title" => "Magic Warrior Cat",
              "description" => "she's magic!",
              "file_type" => "Image"
            },
            "1" => {
              "filename" => "rural_clinics.zip",
              "title" => "Rural Clinics Shapefile",
              "description" => "rural clinics in Georgia",
              "file_type" => "Data"
            }
          }
        },
        "uploaded_files" => ["14", "15", "16"],
        "save_with_files" => "Save",
        "locale" => "en"
      }
    end
    let(:file1) { File.open("#{fixture_path}/miranda/miranda_thesis.pdf") }
    let(:file2) { File.open("#{fixture_path}/magic_warrior_cat.jpg") }
    let(:file3) { File.open("#{fixture_path}/miranda/rural_clinics.zip") }
    before do
      Hyrax::UploadedFile.delete_all
      FactoryGirl.create(:uploaded_file, id: 14, file: file1, user_id: user.id, pcdm_use: "primary")
      FactoryGirl.create(:uploaded_file, id: 15, file: file2, user_id: user.id)
      FactoryGirl.create(:uploaded_file, id: 16, file: file3, user_id: user.id)
    end
    it "attaches metadata to uploaded files" do
      described_class.new.apply_file_metadata(params)
      file15 = Hyrax::UploadedFile.find(15)
      file16 = Hyrax::UploadedFile.find(16)
      expect(file15.title).to eq("Magic Warrior Cat")
      expect(file15.description).to eq("she's magic!")
      expect(file15.file_type).to eq("Image")

      expect(file16.title).to eq("Rural Clinics Shapefile")
      expect(file16.description).to eq("rural clinics in Georgia")
      expect(file16.file_type).to eq("Data")
    end
  end
  context "supplemental file metadata for browse everything files" do
    let(:params) do
      eval(File.read("#{fixture_path}/form_submission_params/files_from_box.rb"))
    end
    it "applies metadata to a ::Hyrax::UploadedFile object" do
      uploaded_file = Hyrax::UploadedFile.create(browse_everything_url: params["uploaded_files"].first)
      described_class.new.apply_metadata_to_uploaded_file(uploaded_file, params)
      expect(uploaded_file.title).to eq "River"
      expect(uploaded_file.description).to eq "in the elephant carrier"
      expect(uploaded_file.file_type).to eq "Image"
      expect(uploaded_file.pcdm_use).to eq FileSet::SUPPLEMENTAL
    end
    it "identifies a primary object" do
      uploaded_file = Hyrax::UploadedFile.create(browse_everything_url: params["uploaded_files"].last)
      described_class.new.apply_metadata_to_uploaded_file(uploaded_file, params)
      expect(uploaded_file.pcdm_use).to eq FileSet::PRIMARY
    end
    it "gets the supplemental file metadata for a given filename" do
      filename = "declan_and_giarlo.JPG"
      metadata = described_class.new.get_supplemental_file_metadata(filename, params)
      expect(metadata["title"]).to eq "Declan and Giarlo"
      expect(metadata["description"]).to eq "DLF 2014"
      expect(metadata["file_type"]).to eq "Software"
      filename = "river.JPG"
      metadata = described_class.new.get_supplemental_file_metadata(filename, params)
      expect(metadata["title"]).to eq "River"
      expect(metadata["description"]).to eq "in the elephant carrier"
      expect(metadata["file_type"]).to eq "Image"
    end
    it "creates an UploadedFile object for each entry in the uploaded_files array" do
      described_class.new.apply_file_metadata(params)
      params["uploaded_files"].each do |be_upload_url|
        expect(::Hyrax::UploadedFile.where(browse_everything_url: be_upload_url).first).to be_instance_of ::Hyrax::UploadedFile
      end
    end
    it "gets the filename for a browse everything uploaded file" do
      uploaded_file = Hyrax::UploadedFile.create(browse_everything_url: params["uploaded_files"].first)
      expected_filename = "river.JPG"
      filename = described_class.new.get_filename_for_uploaded_file(uploaded_file, params)
      expect(filename).to eq expected_filename
    end
    it "gets the url for a filename" do
      expected_url = params["uploaded_files"].first
      url = described_class.new.get_url_for_filename("river.JPG", params)
      expect(url).to eq expected_url
    end
  end
end
