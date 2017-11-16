class ProquestMailer < ApplicationMailer
  default from: Rails.application.config.email_from_address

  def file_transfer(etd_ids)
    @etd_ids = etd_ids
    mail(
      to: Rails.configuration.proquest_notification_email,
      subject: "#{Time.zone.today} Emory Dissertation Submissions",
      body: "
      The following dissertations were submitted from Emory University:

      #{print_etds}

      "
    )
  end

  def print_etds
    print_string = ""
    @etd_ids.each do |etd_id|
      etd = Etd.find(etd_id)
      print_string << "#{etd.creator.first}\t #{etd.export_id}.zip\n"
    end
    print_string
  end
end
