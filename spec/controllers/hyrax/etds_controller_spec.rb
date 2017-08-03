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
      described_class.new.apply_supplemental_file_metadata(params)
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
end
