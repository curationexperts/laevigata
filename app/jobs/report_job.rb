require 'csv'
class ReportJob < ApplicationJob
  def perform
    byebug
    etds = Etd.all

    puts etds.count
    headers = %w[id creator title school department degree submitting_type language subfield research_field keyword committee_chair committee_members post_graduation_email graduation_year partnering_agency date_created date_uploaded abstract_length abstract]

    CSV.open(Rails.root.join("public" "report.csv"), "wb", write_headers: true, headers: headers) do |csv|
      etds.each do |etd|
        csv << headers.map { |x| [etd.send(x)].flatten.first }
      end
    end
  end
end
