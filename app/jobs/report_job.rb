require 'csv'
class ReportJob < ApplicationJob
  def perform
    etds = Etd.where("graduation_date_tesim:*")
    headers = %w[id creator title school department degree submitting_type
                 language subfield research_field keyword committee_chair committee_members
                 post_graduation_email graduation_year degree_awarded graduation_date partnering_agency
                 date_created date_uploaded abstract_length abstract]

    CSV.open(Rails.root.join("public", "report.csv").to_s, "wb", write_headers: true, headers: headers) do |csv|
      etds.each do |etd|
        row = headers.map do |x|
          case x
          when "graduation_year"
            etd.graduation_date
          when "abstract_length"
            etd.abstract.first.length
          else
            k = etd.send(x)
            if k.is_a?(ActiveTriples::Relation)
              k.map { k.first }.join('; ')
            else
              k
            end
          end
        end

        csv << row
      end
    end
    true
  end
end
