require 'etd_factory'

desc "Build sample data"
task :sample_data do
  etd_factory = EtdFactory.new
  etd = FactoryGirl.build(:ateer_etd)
  primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
  etd_factory.etd = etd
  etd_factory.primary_pdf_file = primary_pdf_file
  etd_factory.attach_primary_pdf_file
  puts "Created #{etd.id}"
end
