# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdsController do
  let(:params) do
    {
      "etd" => {
        "no_embargoes" => "1",
        "toc_embargoed" => "",
        "abstract_embargoed" => "",
        "files_embargoed" => ""
      }
    }
  end
  context "selecting no_embargoes" do
    it "sets other embargo fields false" do
      described_class.new.check_for_no_embargoes(params)
      expect(params["etd"]["files_embargoed"]).to eq "false"
      expect(params["etd"]["abstract_embargoed"]).to eq "false"
      expect(params["etd"]["toc_embargoed"]).to eq "false"
    end
  end
end
