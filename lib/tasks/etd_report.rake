require 'csv'
namespace :emory do
  task etd_report: [:environment] do
    headers = %w[id depositor uid creator title school department degree submitting_type
                 language subfield research_field keyword committee_chair committee_members
                 post_graduation_email degree_awarded graduation_date partnering_agency
                 date_created date_uploaded abstract]

    total = ActiveFedora::SolrService.get('workflow_state_name_ssim:published', rows: 0).dig('response', 'numFound')
    index = 0
    CSV.open(Rails.root.join("private", "etd_report.csv").to_s, "wb", write_headers: true, headers: headers) do |csv|
      Etd.search_in_batches({ workflow_state_name_ssim: 'published' }, batch_size: 10) do |batch|
        batch.map { |doc| Etd.find(doc['id']) }.each do |etd|
          row = {}
          headers.map do |field|
            value = etd.try(field)
            row[field] =
              if value.is_a?(ActiveTriples::Relation)
                value.to_a.join('; ')
              else
                value.to_s
              end
          end
          # handle the fields that aren't stored directly in the ETD record
          row['uid'] = User.find_by(ppid: etd.depositor)&.uid
          csv << row
          index += 1
          print "\rProcessed #{index} of #{total}"
          $stdout.flush
        end
      end
    end
    puts "\n\n"
    true
  end
end
