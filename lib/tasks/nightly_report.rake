require 'csv'
namespace :emory do
  task nightly_report: [:environment] do
    headers = %w[id uid creator title school department degree submitting_type
                 language subfield research_field keyword committee_chair committee_members
                 post_graduation_email degree_awarded graduation_date partnering_agency
                 date_created date_uploaded abstract]

    CSV.open(Rails.root.join("private", "report.csv").to_s, "wb", write_headers: true, headers: headers) do |csv|
      Etd.search_in_batches({ workflow_state_name_ssim: 'published' }, batch_size: 10) do |batch|
        batch.map { |x| Etd.find(x['id']) }.each do |etd|
          row = {}
          headers.map do |header|
            value = etd.try(header)
            row[header] =
              if value.is_a?(ActiveTriples::Relation)
                value.to_a.join('; ')
              else
                value.to_s
              end
          end
          # handle the fields that aren't stored directly in the ETD record
          row['uid'] = User.find_by(ppid: etd.depositor).uid
          csv << row
        end
      end
    end
    true
  end
end
