libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

describe Hyrax::UploadedFile do
  let(:file1) { File.open(fixture_path + '/joey/joey_thesis.pdf') }
  let(:uploaded_file) { described_class.create(file: file1) }

  context "new file metadata" do
    it "has a pcdm_use" do
      uploaded_file.pcdm_use = FileSet::PRIMARY
      expect(uploaded_file.pcdm_use).to eq FileSet::PRIMARY
    end
    it "has a browse_everything_url" do
      browse_everything_url =
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
        "2xJaQeBTY3Dmsxx05ItHsO2f6xzACU./download"
      uploaded_file.browse_everything_url = browse_everything_url
      expect(uploaded_file.browse_everything_url).to eq browse_everything_url
    end
  end
end
