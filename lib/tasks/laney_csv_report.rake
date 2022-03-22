require 'csv'

namespace :emory do
  desc "csv reports for Laney Graduate School admins"

  task csv_report: [:environment] do
    puts 'Loading environment...'
    puts 'Starting export...'

    etds = Etd.where(degree: 'Ph.D.', school: 'Laney Graduate School')
    academic_year = ['Fall 2017', 'Spring 2018', 'Summer 2018', 'Fall 2018']
    CSV.open("csv_report.csv", "wb", write_headers: true,
                                     headers: ["Creator", "Advisor", "Committee Members", "Date", "Program"]) do |csv|
      etds.each do |etd|
        creator = etd.creator.to_a
        chair = etd.committee_chair_name.to_a
        members = etd.committee_members_names.to_a
        date =  etd.date_uploaded.to_date
        program = etd.research_field.to_a
        puts etd.graduation_date
        if academic_year.include? etd.graduation_date
          csv << [creator.first, chair.first, members.first, date, program.first]
        end
      end
    end
    puts 'export complete.'
  end
end
