FactoryBot.define do
  factory :etd do
    id { Noid::Rails::Service.new.mint }
    title { [] << FFaker::Book.title }
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    transient do
      user { nil }
    end

    factory :etd_with_toc do
      table_of_contents { [] << FFaker::Lorem.paragraph }
    end

    factory :etd_with_abstract do
      abstract { [] << FFaker::Lorem.paragraph }
    end

    factory :eun_etd do
      title ['China and its Minority Population']
      creator ['Eun, Dongwon']
      keyword ['China', 'Minority Population']
      degree ['MS']
      department ['Religion']
      school ['Laney Graduate School']
      subfield ['Ethics and Society']
      submitting_type ["Honors Thesis"]
      research_field ['Religion, General']

      after(:build) do |etd, evaluator|
        etd.committee_chair.build(FactoryBot.attributes_for(:committee_member))
        etd.committee_members.build(FactoryBot.attributes_for_list(:committee_member, 3))
      end
    end

    factory :ateer_etd do
      creator ['Teer, Drew']
      depositor do
        u = User.new(uid: FFaker::Internet.user_name, ppid: Noid::Rails::Service.new.mint, display_name: creator.first)
        u.save
        u.user_key
      end
      title ['Investigating and Developing a Novel Implicit Measurement of Self-Esteem']
      keyword ['classical conditioning', 'implict', 'self-esteem']
      submitting_type ["Master's Thesis"]
      research_field ['Clinical Psychology']
      school ['Laney Graduate School']
      admin_set do
        AdminSet.where(title: 'Laney Graduate School').first
      end
      department ['Psychology']
      subfield []
      degree ['MA']
      language ['English']
      graduation_year "2016"
      abstract { [] << FFaker::Lorem.paragraph }
      table_of_contents { [] << FFaker::Lorem.paragraph }
      # 2017-08-21 is the actual date of this embargo expiration, but now that it
      # is no longer in the future, it is no longer a valid embargo date. Leaving
      # it here as a point of discussion for future migration work.
      # embargo_id { FactoryBot.create(:embargo, embargo_release_date: "2017-08-21").id }
      files_embargoed true
      abstract_embargoed true
      toc_embargoed true
      identifier ['ark:/25593/rpj6m']
      legacy_id ['ark:/25593/rpj8w', 'ark:/25593/rpj91', 'ark:/25593/rpj6m']
      # file_format ['application/pdf']
      post_graduation_email ['redacted@example.com']
      # permanent_address ['123 Sesame St, Atlanta, GA 30306, UNITED STATES']

      after(:build) do |etd, evaluator|
        etd.committee_chair.build(FactoryBot.attributes_for(:committee_member, name: ['Treadway, Michael T']))
        etd.committee_members.build(FactoryBot.attributes_for(:committee_member, name: ['Craighead, W Edward']))
        etd.committee_members.build(FactoryBot.attributes_for(:committee_member, name: ['Manns, Joseph']))
      end
    end

    factory :sample_data do
      creator { [] << "#{FFaker::Name.last_name}, #{FFaker::Name.first_name}" }
      graduation_year "2017"
      school ["Candler School of Theology"]
      post_graduation_email { [] << FFaker::Internet.email }
      admin_set do
        AdminSet.where(title: "Candler School of Theology").first
      end
      depositor do
        u = User.new(uid: FFaker::Internet.user_name, ppid: Noid::Rails::Service.new.mint, display_name: creator.first)
        u.save
        u.user_key
      end
      table_of_contents { [] << FFaker::Lorem.paragraph }
      abstract { [] << FFaker::Lorem.paragraph }
      title ["Sample Data: #{FFaker::Book.title}"]
      department ["Divinity"]
      subfield ["Political Robotics"]
      research_field ["Artificial Intelligence", "Canadian Studies", "Folklore"]
      degree ["Th.D."]
      submitting_type ["Dissertation"]
      language ["English"]
      keyword [FFaker::Education.major, FFaker::Education.major, FFaker::Education.major]

      after(:build) do |etd, evaluator|
        etd.committee_chair.build(
          name: ["#{FFaker::Name.last_name}, #{FFaker::Name.first_name}"],
          affiliation: [FFaker::Education.school],
          netid: [FFaker::Internet.user_name]
        )
        etd.committee_members.build(
          name: ["#{FFaker::Name.last_name}, #{FFaker::Name.first_name}"],
          affiliation: [FFaker::Education.school],
          netid: [FFaker::Internet.user_name]
        )
        etd.committee_members.build(
          name: ["#{FFaker::Name.last_name}, #{FFaker::Name.first_name}"],
          affiliation: [FFaker::Education.school],
          netid: [FFaker::Internet.user_name]
        )
      end

      # this factory returns string values for booleans
      # because the solr_document methods return strings in the feature tests, although not from the application.
      factory :sample_data_with_copyright_questions do
        title ["Sample Data With Copyrights: #{FFaker::Book.title}"]
        copyright_question_one "true"
        copyright_question_two "false"
        copyright_question_three "true"
      end

      factory :sample_data_with_everything_embargoed do
        title ["Sample Data With Full Embargo: #{FFaker::Book.title}"]
        embargo { FactoryBot.create(:embargo, embargo_release_date: (Time.zone.today + 14.days)) }
        embargo_length "6 months"
        files_embargoed "true"
        abstract_embargoed "true"
        toc_embargoed "true"

        factory :sixty_day_expiration do
          degree_awarded { Time.zone.today - 2.years }
          embargo { FactoryBot.create(:embargo, embargo_release_date: (Time.zone.today + 60.days)) }
        end

        factory :seven_day_expiration do
          degree_awarded { Time.zone.today - 2.years }
          embargo { FactoryBot.create(:embargo, embargo_release_date: (Time.zone.today + 7.days)) }
        end

        factory :tomorrow_expiration do
          degree_awarded { Time.zone.today - 2.years }
          embargo { FactoryBot.create(:embargo, embargo_release_date: Time.zone.tomorrow) }
        end

        factory :sample_data_with_only_files_embargoed do
          title ["Sample Data With File Embargo: #{FFaker::Book.title}"]
          abstract_embargoed false
          toc_embargoed false
        end
      end
      factory :ready_for_proquest_submission_phd do
        title ["ProQuest PhD: #{FFaker::Book.title}"]
        degree_awarded { (Time.zone.today - 1.week).strftime('%Y-%m-%d') }
        submitting_type { [] << "Dissertation" }
        school ["Laney Graduate School"]
        admin_set do
          AdminSet.where(title: "Laney Graduate School").first
        end
        degree ["PhD"]
      end
    end
  end
end
