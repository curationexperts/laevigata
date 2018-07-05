require 'rails_helper'

describe InProgressEtd do
  before(:all) do
    new_ui = Rails.application.config_for(:new_ui).fetch('enabled', false)

    skip("InProgress ETD model tests run only when NEW_UI_ENABLED") unless new_ui
  end

  describe "About Me" do
    context "with valid data" do
      let(:data) do
        { currentTab: "About Me", creator: "Student", graduation_date: "tomorrow", post_graduation_email: "tester@test.com", school: "Laney Graduate School" }
      end
      let(:in_progress_etd) { described_class.new(data: data.to_json) }

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

    context "with missing school and graduation_date" do
      let(:in_progress_etd) { described_class.new(data: { currentTab: "About Me", creator: "Student", post_graduation_email: "" }.to_json) }

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end
  end

  describe "My Program" do
    context "with valid data" do
      let(:data) do
        { currentTab: "My Program", department: "Anthropology", subfield: "Foo", partnering_agency: "DCD", degree: "Non", submitting_type: "Phd" }
      end
      let(:in_progress_etd) { described_class.new(data: data.to_json) }

      it "is valid" do
        expect(in_progress_etd).to be_valid
      end
    end

    context "with invalid data" do
      let(:data) do
        { currentTab: "My Program", department: "", subfield: "Foo", partnering_agency: "DCD", degree: "Non", submitting_type: "" }
      end
      let(:in_progress_etd) { described_class.new(data: data.to_json) }

      it "is not valid" do
        expect(in_progress_etd).not_to be_valid
      end
    end
  end
end
