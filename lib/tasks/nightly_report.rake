require 'csv'
class ReportJob < ApplicationJob
  def perform
    headers = %w[id uid creator title school department degree submitting_type
                 language subfield research_field keyword committee_chair committee_members
                 post_graduation_email graduation_year degree_awarded graduation_date partnering_agency
                 date_created date_uploaded abstract_length abstract]

    CSV.open(Rails.root.join("public/report.csv").to_s, "wb", write_headers: true, headers: headers) do |csv|
      Etd.search_in_batches({ workflow_state_name_ssim: 'published' }, batch_size: 10) do |batch|
        batch.map { |x| Etd.find(x['id']) }.each do |etd|
          row = headers.map do |x|
            case x
            when "uid"
              User.find_by(ppid: etd.depositor).uid
            when "graduation_year"
              etd.graduation_date
            when "abstract_length"
              etd.abstract.first.length
            else
              k = etd.send(x)
              if k.is_a?(ActiveTriples::Relation)
                k.map { k.first }.join('; ').tr("\n", ' ')
              elsif k.is_a?(String)
                k.gsub('\n', ' ')
              else
                k
              end
            end
          end
          puts etd.id
          csv << row
        end
      end
    end
    true
  end
end
