require 'etd_factory'
Rails.application.config.active_job.queue_adapter = :inline

namespace :sample_data do
  desc "Build basic sample data"
  task :basic do
    sample_data = [:sample_data, :sample_data_with_everything_embargoed, :sample_data_with_only_files_embargoed, :ateer_etd]
    sample_data.each do |s|
      RSpec::Mocks.with_temporary_scope do
        user = FactoryBot.create(:user)
        etd = FactoryBot.create(
          s,
          submitting_type: ["Master's Thesis"],
          school: ["Rollins School of Public Health"],
          department: ["Epidemiology"],
          degree: ["M.S."],
          subfield: ["Political Robotics"],
          depositor: user.user_key
        )
        upload1 = FactoryBot.create(:primary_uploaded_file, user_id: user.id)
        upload2 = FactoryBot.create(:uploaded_image_file, user_id: user.id)
        upload3 = FactoryBot.create(:uploaded_data_file, user_id: user.id)
        attributes_for_actor = { uploaded_files: [upload1.id, upload2.id, upload3.id] }
        env = Hyrax::Actors::Environment.new(etd, ::Ability.new(user), attributes_for_actor)
        Hyrax::CurationConcern.actor.create(env)
      end
    end
  end

  desc "Build sample data for all admin sets"
  task :workflow do
    sample_data = [:sample_data, :sample_data_with_everything_embargoed, :sample_data_with_only_files_embargoed]
    school_based_admin_sets = ["Laney Graduate School", "Emory College", "Candler School of Theology"]
    admin_sets = YAML.safe_load(File.read("#{::Rails.root}/config/emory/admin_sets.yml")).keys
    admin_sets.each do |as|
      puts "Making sample data for #{as}"
      sample_data.each do |s|
        RSpec::Mocks.with_temporary_scope do
          user = FactoryBot.create(:user)
          etd = FactoryBot.build(s, submitting_type: ["Master's Thesis"], degree: ["M.S."], depositor: user.id)
          if school_based_admin_sets.include?(as)
            etd.school = [as]
          else
            etd.school = ["Rollins School of Public Health"]
            etd.department = [as]
          end
          etd.save
          ability = ::Ability.new(user)
          upload1 = FactoryBot.create(:primary_uploaded_file, user_id: user.id)
          upload2 = FactoryBot.create(:uploaded_image_file, user_id: user.id)
          attributes_for_actor = { uploaded_files: [upload1.id, upload2.id] }
          env = Hyrax::Actors::Environment.new(etd, ability, attributes_for_actor)
          Hyrax::CurationConcern.actor.create(env)
          puts "Created #{etd.id}"
        end
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

    attributes_for_actor = { requested_embargo_duration: etd.embargo_length, uploaded_files: [upload1.id, upload2.id] }
    env = Hyrax::Actors::Environment.new(etd, ability, attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)

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

    attributes_for_actor = { uploaded_files: [upload1.id, upload2.id] }
    env = Hyrax::Actors::Environment.new(etd, ability, attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)

    approving_user = User.where(ppid: 'tezprox').first
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

  desc "Export sample ProQuest package, upload it via sftp"
  task :proquest_export do
    puts "Exporting sample ProQuest package"
    etd = proquest_demo
    ProquestJob.perform_now(etd.id)
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

    attributes_for_actor = { uploaded_files: [upload1.id, upload2.id] }
    env = Hyrax::Actors::Environment.new(etd, ability, attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)
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

      attributes_for_actor = { uploaded_files: [upload1.id, upload2.id] }
      env = Hyrax::Actors::Environment.new(etd, ability, attributes_for_actor)
      Hyrax::CurationConcern.actor.create(env)

      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Preapproved")
      puts "Built #{etd.id}"
    end
  end
end
