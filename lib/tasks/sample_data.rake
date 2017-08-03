require 'etd_factory'

namespace :sample_data do
  desc "Build basic sample data"
  task :basic do
    sample_data = [:sample_data, :sample_data_with_everything_embargoed, :sample_data_with_only_files_embargoed, :ateer_etd]
    sample_data.each do |s|
      etd_factory = EtdFactory.new
      etd = FactoryGirl.create(
        s,
        submitting_type: ["Master's Thesis"],
        school: ["Rollins School of Public Health"],
        department: ["Epidemiology"],
        degree: ["M.S."],
        subfield: ["Political Robotics"]
      )
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

  task :workflow do
    sample_data = [:sample_data, :sample_data_with_everything_embargoed, :sample_data_with_only_files_embargoed]
    school_based_admin_sets = ["Laney Graduate School", "Emory College", "Candler School of Theology"]
    admin_sets = YAML.safe_load(File.read("#{::Rails.root}/config/emory/admin_sets.yml")).keys
    admin_sets.each do |as|
      puts "Making sample data for #{as}"
      sample_data.each do |s|
        etd = FactoryGirl.build(s, submitting_type: ["Master's Thesis"], degree: ["M.S."])
        if school_based_admin_sets.include?(as)
          etd.school = [as]
        else
          etd.school = ["Rollins School of Public Health"]
          etd.department = [as]
        end
        etd.assign_admin_set
        user = User.where(ppid: etd.depositor).first
        ability = ::Ability.new(user)

        file1 = File.open("#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf")
        file2 = File.open("#{::Rails.root}/spec/fixtures/miranda/image.tif")
        upload1 = Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: 'primary')
        upload2 = Hyrax::UploadedFile.create(user: user, file: file2, pcdm_use: 'supplementary')
        actor = Hyrax::CurationConcern.actor(etd, ability)
        attributes_for_actor = { uploaded_files: [upload1.id, upload2.id] }
        actor.create(attributes_for_actor)
        puts "Created #{etd.id}"
      end
    end
  end

  task :embargo_demo do
    etd = FactoryGirl.create(
      :sample_data_with_everything_embargoed,
      title: ["Embargo Demo: #{FFaker::Book.title}"],
      school: ["Candler School of Theology"]
    )
    etd_factory = EtdFactory.new
    primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
    etd_factory.etd = etd
    etd_factory.primary_pdf_file = primary_pdf_file
    etd_factory.attach_primary_pdf_file
    etd_factory.supplemental_files = ["#{::Rails.root}/spec/fixtures/miranda/rural_clinics.zip", "#{::Rails.root}/spec/fixtures/miranda/image.tif"]
    etd_factory.attach_supplemental_files
    etd.save
    puts "Created #{etd.id}"
  end

  desc "Build sample data to demo daily jobs (graduation and embargo expiration)"
  task :daily_jobs_demo do
    puts "Making preapproved embargo data"
    etd = FactoryGirl.create(
      :sample_data_with_everything_embargoed,
      title: ["Daily Jobs Demo: #{FFaker::Book.title}"],
      submitting_type: ["Master's Thesis"],
      degree: ["M.S."],
      school: ['Candler School of Theology']
    )
    etd.assign_admin_set
    user = User.where(ppid: etd.depositor).first
    ability = ::Ability.new(user)
    file1 = File.open("#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf")
    file2 = File.open("#{::Rails.root}/spec/fixtures/miranda/image.tif")
    upload1 = Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: 'primary')
    upload2 = Hyrax::UploadedFile.create(user: user, file: file2, pcdm_use: 'supplementary')
    actor = Hyrax::CurationConcern.actor(etd, ability)
    attributes_for_actor = { embargo_length: etd.embargo_length, uploaded_files: [upload1.id, upload2.id] }
    actor.create(attributes_for_actor)
    approving_user = User.where(ppid: 'candleradmin').first
    subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
    sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Preapproved")
    puts "Created #{etd.id}"
  end

  desc "Build sample data to demo embargo expiration service"
  task :embargo_expiration do
    approving_user = User.where(ppid: 'candleradmin').first
    [:sixty_day_expiration, :seven_day_expiration, :tomorrow_expiration].each do |e|
      etd = FactoryGirl.create(
        e,
        title: ["Embargo Expiration Demo: #{FFaker::Book.title}"],
        school: ['Candler School of Theology']
      )
      user = User.where(ppid: etd.depositor).first
      ability = ::Ability.new(user)
      file1 = File.open("#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf")
      file2 = File.open("#{::Rails.root}/spec/fixtures/miranda/image.tif")
      upload1 = Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: 'primary')
      upload2 = Hyrax::UploadedFile.create(user: user, file: file2, pcdm_use: 'supplementary')
      actor = Hyrax::CurationConcern.actor(etd, ability)
      attributes_for_actor = { uploaded_files: [upload1.id, upload2.id] }
      actor.create(attributes_for_actor)
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Preapproved")
      puts "Built #{etd.id}"
    end
  end
end
