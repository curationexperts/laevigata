require 'etd_factory'

desc "Build sample data"
task :sample_data do
  sample_data = [:sample_data, :sample_data_with_everything_embargoed, :sample_data_with_only_files_embargoed, :ateer_etd]
  sample_data.each do |s|
    etd_factory = EtdFactory.new
    etd = FactoryGirl.create(s)
    primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
    etd_factory.etd = etd
    etd_factory.primary_pdf_file = primary_pdf_file
    etd_factory.attach_primary_pdf_file
    etd_factory.supplemental_files = ["#{::Rails.root}/spec/fixtures/miranda/rural_clinics.zip", "#{::Rails.root}/spec/fixtures/miranda/image.tif"]
    etd_factory.attach_supplemental_files
    etd_factory.etd.save
    puts "Created #{etd.id}"
  end
end
task :sample_data_with_workflow do
  sample_data = [:sample_data, :sample_data_with_everything_embargoed, :sample_data_with_only_files_embargoed]
  school_based_admin_sets = ["Laney Graduate School", "Emory College", "Candler School of Theology"]
  admin_sets = YAML.safe_load(File.read("#{::Rails.root}/config/emory/admin_sets.yml")).keys
  admin_sets.each do |as|
    puts "Making sample data for #{as}"
    sample_data.each do |s|
      etd = FactoryGirl.build(s)
      if school_based_admin_sets.include?(as)
        etd.school = [as]
      else
        etd.school = ["Rollins School of Public Health"]
        etd.department = [as]
      end
      etd.assign_admin_set
      user = User.where(ppid: etd.depositor).first
      ability = ::Ability.new(user)
      actor = Hyrax::CurationConcern.actor(etd, ability)
      # TODO: Figure out how to attach files via the actor.create hash
      # actor.create(admin_set_id: etd.admin_set.id, files: [Hyrax::UploadedFile.create(file: File.open("#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"))])
      actor.create(admin_set_id: etd.admin_set.id)
      puts "Created #{etd.id}"
    end
  end
end
