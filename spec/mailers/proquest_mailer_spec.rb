require "rails_helper"

RSpec.describe ProquestMailer, type: :mailer do
  let(:etd1) { FactoryGirl.create(:sample_data) }
  let(:etd2) { FactoryGirl.create(:sample_data) }
  it "accepts an array of work ids" do
    msg = ProquestMailer.file_transfer([etd1.id, etd2.id])
    expect(msg.to).to include("proquest@example.com")
    expect(msg.from).to include("test@example.com")
    expect(msg.subject).to match(/Emory Dissertation Submissions/)
    expect(msg.body.raw_source).to match(etd1.creator.first)
    expect(msg.body.raw_source).to match(etd2.creator.first)
  end
end
