require 'etd_factory'
Rails.application.config.active_job.queue_adapter = :inline

namespace :sample_data do
  desc "Build basic sample data"
  task :basic do
    sample_data = [:sample_data, :sample_data_with_everything_embargoed, :sample_data_with_only_files_embargoed, :ateer_etd]
    sample_data.each do |s|
      etd_factory = EtdFactory.new
      etd = FactoryBot.create(
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

  desc "Sample data with supplementary file metadata"
  task :with_supplementary_file_metadata do
    puts "Making sample data with supplementary file metadata"
    sample_data = [
      :sample_data,
      :sample_data_with_everything_embargoed,
      :sample_data_with_only_files_embargoed
    ]
    sample_data.each do |s|
      etd = FactoryBot.create(s)
      uploaded_files = []
      primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
      supplementary_file_one = "#{::Rails.root}/spec/fixtures/miranda/rural_clinics.zip"
      supplementary_file_two = "#{::Rails.root}/spec/fixtures/miranda/image.tif"
      uploaded_files << Hyrax::UploadedFile.create(
        file: File.open(primary_pdf_file),
        pcdm_use: FileSet::PRIMARY
      )
      uploaded_files << Hyrax::UploadedFile.create(
        file: File.open(supplementary_file_one),
        pcdm_use: FileSet::SUPPLEMENTARY,
        title: "Rural Clinics in Georgia",
        description: "GIS shapefile showing rural clinics",
        file_type: "Dataset"
      )
      uploaded_files << Hyrax::UploadedFile.create(
        file: File.open(supplementary_file_two),
        pcdm_use: FileSet::SUPPLEMENTARY,
        title: "Photographer",
        description: "a portrait of the artist",
        file_type: "Image"
      )
      AttachFilesToWorkJob.perform_now(etd, uploaded_files)
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
        etd = FactoryBot.build(s, submitting_type: ["Master's Thesis"], degree: ["M.S."])
        if school_based_admin_sets.include?(as)
          etd.school = [as]
        else
          etd.school = ["Rollins School of Public Health"]
          etd.department = [as]
        end
        etd.assign_admin_set
        user = User.where(ppid: etd.depositor).first
        ability = ::Ability.new(user)

        file1_path = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
        file2_path = "#{::Rails.root}/spec/fixtures/miranda/image.tif"
        upload1 = File.open(file1_path) do |file1|
          Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: 'primary')
        end
        upload2 = File.open(file2_path) do |file2|
          Hyrax::UploadedFile.create(user: user, file: file2, pcdm_use: 'supplementary')
        end
        actor = Hyrax::CurationConcern.actor(etd, ability)
        attributes_for_actor = { uploaded_files: [upload1.id, upload2.id] }
        actor.create(attributes_for_actor)
        puts "Created #{etd.id}"
      end
    end
  end

  task :embargo_demo do
    etd = FactoryBot.create(
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
    etd = FactoryBot.create(
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

  def proquest_demo
    etd = FactoryBot.create(:ready_for_proquest_submission_phd)
    etd.assign_admin_set
    user = User.where(ppid: etd.depositor).first
    ability = ::Ability.new(user)
    file1_path = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
    file2_path = "#{::Rails.root}/spec/fixtures/miranda/image.tif"
    upload1 = File.open(file1_path) { |file1|
      Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: 'primary')
    }
    upload2 = File.open(file2_path) { |file2|
      Hyrax::UploadedFile.create(
        user: user,
        file: file2,
        pcdm_use: 'supplementary',
        description: 'Description of the supplementary file',
        file_type: 'Image'
      )
    }
    actor = Hyrax::CurationConcern.actor(etd, ability)
    attributes_for_actor = { uploaded_files: [upload1.id, upload2.id] }
    actor.create(attributes_for_actor)
    approving_user = User.where(ppid: 'laneyadmin').first
    subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
    sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Preapproved")
    etd.state = Vocab::FedoraResourceStatus.active # simulates GraduationJob
    etd.save
    etd
  end

  desc "Build sample data to demo ProQuest submission"
  task :proquest_demo do
    puts "Making ProQuest ready data"
    etd = proquest_demo
    puts "Created #{etd.id}"
  end

  desc "Export sample ProQuest package"
  task :proquest_export do
    puts "Exporting sample ProQuest package"
    etd = proquest_demo
    ProquestJob.perform_now(etd)
    export_location = "#{etd.export_directory}/#{etd.upload_file_id}.zip"
    puts "ProQuest sample exported to #{export_location}"
  end

  def virus_demo
    etd = FactoryBot.create(:sample_data)
    etd.assign_admin_set
    user = User.where(ppid: etd.depositor).first
    ability = ::Ability.new(user)
    file1_path = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
    file2_path = "#{::Rails.root}/spec/fixtures/virus_checking/virus_check.txt"
    upload1 = File.open(file1_path) { |file1|
      Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: 'primary')
    }
    upload2 = File.open(file2_path) { |file2|
      Hyrax::UploadedFile.create(
        user: user,
        file: file2,
        pcdm_use: 'supplementary',
        title: 'Virus',
        description: 'payload',
        file_type: 'Software'
      )
    }
    actor = Hyrax::CurationConcern.actor(etd, ability)
    attributes_for_actor = { uploaded_files: [upload1.id, upload2.id] }
    actor.create(attributes_for_actor)
    etd
  end

  desc "Build sample data to demo virus checking"
  task :virus do
    puts "Making virus infected ETD"
    etd = virus_demo
    puts "Created #{etd.id}"
  end

  desc "Build sample data to demo embargo expiration service"
  task :embargo_expiration do
    approving_user = User.where(ppid: 'candleradmin').first
    [:sixty_day_expiration, :seven_day_expiration, :tomorrow_expiration].each do |e|
      etd = FactoryBot.create(
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
