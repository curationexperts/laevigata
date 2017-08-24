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
  context "supplemental file metadata for browse everything files" do
    let(:params) do
      {
        "etd" =>  {
          "title" => "Browse Everything Test",
          "no_supplemental_files" => "0",
          "supplemental_file_metadata" => {
            "0" => {
              "filename" => "IMG_1372.JPG",
              "title" => "Giarlo and Declan",
              "description" => "so funny!",
              "file_type" => "Image"
            }
          }
        },
        "uploaded_files" =>
          [
            "https://public.boxcloud.com/d/1/7iunLOqXe8wNfrer-fiKFmNL" \
            "67Rokvce5vpp6aI4-KvOL2YddAu8Zz0TTp5aCF1qcL8mK7GMde8SEF1NZ" \
            "f7kwrogmF3M_Rxh6IVEj4sWxk0uJ3xg-hskwgcWRzyIQV6j3OnXjP80um" \
            "sx196WCEwTTRkjK0507txBEzsWyRnvl18ndmZGRanVXQA2itQX9DcWKd8" \
            "zxazo7AF2ALpJSwMyV9PMeHTpVtuLbGwyoWaaVALxVzhIUlavW97j39FF" \
            "KAGmQ4MzStu5kkNbk6ZPCSUnfT3X5OAKz3RPO_feRxCjcctOVmGUJVh1vSK" \
            "facapNHk3mS-JAE0O8_E9zqxT7I23glB_hM8VGyEwEHBzGkL-NCb1mjrOh" \
            "6ghumPy9FjIySdYf9yyxX_ArLynsPaBrTHZ4rgTLfMRw42F1cgfb2wObe" \
            "QMyXPaI8qbffBKLsobZC9WLhIkghfWgi-CZzANYkTu7uJ5_rAcshDC9Uf" \
            "Io5ag4LCYAHsfw2d7iaF0G6G7sXxPfNNSKcEMzOTvzoOYd8TAn67ezda3" \
            "Ix1H7aV6-xha7wb_0DqlNSh47jQa1qQoFSNB08DEjIjQlVzgFvAuN9x9" \
            "TVRlrB2NcGJrgwd0ZttJJRBSTgR3Kef01F8Wnt4cvLzuFuumwJ2qw1rX" \
            "gvhFcxph0fMo5H3vS6j3SiTbpCRNPmgeh5Bi0FWe0BUXi5bUXgaLzvgYJ" \
            "TdwvykuzEu4PJS58_a03v5AZPwCMprDsPxtnJpiM6kCUovOMhLt65943u" \
            "cc1uvITe2KbNPJS2cCCwtC_6zy186ayXBMSlc_ReLOPZR029N38qDR5P3s5" \
            "Ez8lv2ABBSoQPGz8xUpWKVnqD4EuS_jg_0OeNrOZ07DC_2S507jt7MQeJ" \
            "8u65N607haYRz6Cfa9C8AkBDLkeMQEyR9cwIm0UdznF53CTN_SORoVFFP" \
            "-6kz6Xrz3WxQpO3JsQ-CHaHmdqsZoS2uZvFoLU6O6JHoL7mCp1uvvJUj3" \
            "ruGMQwqAOVG9UNX2qO5-KcGp0zmVemj2duuWJI74PxDvlb2KpXU7TONKu" \
            "MLB2xJaQeBTY3Dmsxx05ItHsO2f6xzACU./download",
            "https://public.boxcloud.com/d/1/B7JZEXeY60ANYjfw0p7NLpy3" \
            "NHBAx8IZ4awfr5g3seaNRFpZOtWP386VAeYovL03hxnzRdYAruuSjjbXg" \
            "HiVdYIBIHaPyDeuxw0QhsCcoZpW4SMbQ0aXuN_PKjsJJsbtuwCjTzH8Sk" \
            "GzJ2Gg2gq8wPQgL29QcYD1FPdjCEisWH7vKEIDyNvJ69Qb-yP5roBst1D" \
            "sFLLEtiDy7vUZ6ip3o6eey5N-vlpjyIzv6q71B-Ns_dmgWk8UL_B9Kisz" \
            "wzAC3ifSf1hyR8I-MCLhz_7vJCI9d3DGaMEk0kttv1UE4gyPd2l4bD9HQ" \
            "il-FKR1OEB5J2uoK0FDRqfVzemHvflqJDO80BPAGtjXfPOhX1HauMHMta6" \
            "jGWYchET4GXrGJ39xNw3_ox89YbH-1pRJv7orpZd76DQS1WgccAXG0TIU" \
            "25QaIM3vlq8SqfxoHsNDzS8AIfaBbHQzVkipRCq-etYb-O85R5Oh8leKL" \
            "TV_l1BUqlmvDmqrAC1EgwyWCUXjg3eJt4UwRRQnNtTzkGPmLebN9m2OoYW" \
            "imtBq-fQZoLMupq8KUduIwHBa9aB9-979iOisWQXdNnuov-J70bkVuu8qq" \
            "FySybHgsiCihO1NM98XCuiMfVEcTByi1-vToCGVIcV5QO1AlEw_wi6KMk" \
            "BtUZo3JZ0Mqvwh8tiw2VqkvxTvfmNG2FOPsAOESrwXNP3Z4rHWV4DIbf-v" \
            "Xsq9WOs5b8ci4xTq-ofHam3cw-iOKxUGrMQT5dXnS5BPrB_Elzc3EtQJBf" \
            "bk3_twulZM7Hjmsick1iByLi-BLHTGo_vzmkAe-yxVVAXl9vUAD9ugcadSS" \
            "WmT_Eh3XD2TBaNBthjFfrBz0Jz6pREblVkX5UoCRMT82tau6q7SehNOb7O" \
            "N5Kl5OACYCRcN7ghEgkG0hRKwOUJ7uRsR6VLnnfnAb3BUg8UfISLoEpE8Y" \
            "A4EiYJdG8nwThkYER7MoidDlx2cTQOJDmgECpi-DUm413-Gk-eemv3XPZx" \
            "-iQUHvtgAL9TclnhvDR_T7cvdTiOEtwBJ3x5FE0hxTX2jN0hI9FD-kA4r" \
            "r06aquETLdfhKv17tNaSVXQttJgsi3oLxkQ./download"
          ],
        "selected_files" =>
          {
            "0" =>
              {
                "url" =>
                  "https://public.boxcloud.com/d/1/7iunLOqXe8wNfrer-fiKFmNL" \
                  "67Rokvce5vpp6aI4-KvOL2YddAu8Zz0TTp5aCF1qcL8mK7GMde8SEF1" \
                  "NZf7kwrogmF3M_Rxh6IVEj4sWxk0uJ3xg-hskwgcWRzyIQV6j3OnXj" \
                  "P80umsx196WCEwTTRkjK0507txBEzsWyRnvl18ndmZGRanVXQA2itQ" \
                  "X9DcWKd8zxazo7AF2ALpJSwMyV9PMeHTpVtuLbGwyoWaaVALxVzhIU" \
                  "lavW97j39FFKAGmQ4MzStu5kkNbk6ZPCSUnfT3X5OAKz3RPO_feRxC" \
                  "jcctOVmGUJVh1vSKfacapNHk3mS-JAE0O8_E9zqxT7I23glB_hM8VGy" \
                  "EwEHBzGkL-NCb1mjrOh6ghumPy9FjIySdYf9yyxX_ArLynsPaBrTHZ4" \
                  "rgTLfMRw42F1cgfb2wObeQMyXPaI8qbffBKLsobZC9WLhIkghfWgi" \
                  "-CZzANYkTu7uJ5_rAcshDC9UfIo5ag4LCYAHsfw2d7iaF0G6G7sXx" \
                  "PfNNSKcEMzOTvzoOYd8TAn67ezda3Ix1H7aV6-xha7wb_0DqlNSh47" \
                  "jQa1qQoFSNB08DEjIjQlVzgFvAuN9x9-TVRlrB2NcGJrgwd0ZttJJRB" \
                  "STgR3Kef01F8Wnt4cvLzuFuumwJ2qw1rXgvhFcxph0fMo5H3vS6j3Si" \
                  "TbpCRNPmgeh5Bi0FWe0BUXi5bUXgaLzvgYJTdwvykuzEu4PJS58_" \
                  "a03v5AZPwCMprDsPxtnJpiM6kCUovOMhLt65943ucc1uvITe2KbNPJS" \
                  "2cCCwtC_6zy186ayXBMSlc_ReLOPZR029N38qDR5P3s5Ez8lv2ABBSo" \
                  "QPGz8xUpWKVnqD4EuS_jg_0OeNrOZ07DC_2S507jt7MQeJ8u65N607h" \
                  "aYRz6Cfa9C8AkBDLkeMQEyR9cwIm0UdznF53CTN_SORoVFFP-6kz6X" \
                  "rz3WxQpO3JsQ-CHaHmdqsZoS2uZvFoLU6O6JHoL7mCp1uvvJUj3ruGM" \
                  "QwqAOVG9UNX2qO5-KcGp0zmVemj2duuWJI74PxDvlb2KpXU7TONKuMLB" \
                  "2xJaQeBTY3Dmsxx05ItHsO2f6xzACU./download",
                "auth_header" =>
                  {
                    "Authorization" =>
                      "Bearer {\"token\"=>\"JlyWOq4WKYL5GnF" \
                      "ex5lrg6ZRs6XfjsB0\", \"refresh_token\"=>\"6sh4f6jSsP" \
                      "HQ48wO9xugDqvwZaPZJoItqDrJfNe8eTNXj8JfEHK19IdWvvTPDAMM\"," \
                      " \"expires_at\"=>1503591545}"
                  },
                  "expires" => "2017-08-24T16:24:43.209Z",
                  "file_name" => "IMG_1372.JPG",
                  "file_size" => "1260434"
              }
            },
        "locale" => "en"
      }
    end
    it "can read the params value" do
      puts params
    end
    it "attaches metadata to browse-everything uploaded files" do
      described_class.new.apply_supplemental_file_metadata(params)
    end
  end
end
