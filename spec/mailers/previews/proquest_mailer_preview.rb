# Preview all emails at http://localhost:3000/rails/mailers/proquest_mailer
class ProquestMailerPreview < ActionMailer::Preview
  let(:etd1) { FactoryGirl.create(:sample_data) }
  let(:etd2) { FactoryGirl.create(:sample_data) }
  def file_transfer_preview
    ProquestMailer.file_transfer([etd1.id, etd2.id])
  end
end
