FactoryGirl.define do
  factory :etd do
    id { ActiveFedora::Noid::Service.new.mint }
    title { [] << FFaker::Book.title }
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

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
      committee_chair [FactoryGirl.build(:committee_member)]
      committee_members FactoryGirl.build_list(:committee_member, 3)
    end

    factory :ateer_etd do
      creator ['Teer, Drew']
      depositor do
        u = User.new(uid: FFaker::Internet.user_name, ppid: ActiveFedora::Noid::Service.new.mint, display_name: creator.first)
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
      committee_chair [
        FactoryGirl.build(:committee_member, name: 'Treadway, Michael T')
      ]
      committee_members [
        FactoryGirl.build(:committee_member, name: 'Craighead, W Edward'),
        FactoryGirl.build(:committee_member, name: 'Manns, Joseph')
      ]
      embargo_id { FactoryGirl.create(:embargo, embargo_release_date: "2017-08-21").id }
      files_embargoed true
      abstract_embargoed true
      toc_embargoed true
      identifier ['ark:/25593/rpj6m']
      legacy_id ['ark:/25593/rpj8w', 'ark:/25593/rpj91', 'ark:/25593/rpj6m']
      # file_format ['application/pdf']
      post_graduation_email ['redacted@example.com']
      # permanent_address ['123 Sesame St, Atlanta, GA 30306, UNITED STATES']
    end

    factory :sample_data do
      creator { [] << FFaker::Name.name }
      graduation_year "2017"
      school ["Candler School of Theology"]
      post_graduation_email { [] << FFaker::Internet.email }
      admin_set do
        AdminSet.where(title: "Candler School of Theology").first
      end
      depositor do
        u = User.new(uid: FFaker::Internet.user_name, ppid: ActiveFedora::Noid::Service.new.mint, display_name: creator.first)
        u.save
        u.user_key
      end
      table_of_contents { [] << FFaker::Lorem.paragraph }
      abstract { [] << FFaker::Lorem.paragraph }
      title ["Sample Data: #{FFaker::Book.title}"]
      committee_chair [
        FactoryGirl.build(:committee_member, name: FFaker::NameCS.name)
      ]
      committee_members [
        FactoryGirl.build(:committee_member, name: FFaker::NameRU.name),
        FactoryGirl.build(:committee_member, name: FFaker::NameVN.name)
      ]
      department ["Divinity"]
      subfield ["Political Robotics"]
      degree ["Th.D."]
      submitting_type ["Dissertation"]
      language ["English"]
      keyword [FFaker::Education.major, FFaker::Education.major, FFaker::Education.major]

      factory :sample_data_with_everything_embargoed do
        title ["Sample Data With Full Embargo: #{FFaker::Book.title}"]
        embargo { FactoryGirl.create(:embargo, embargo_release_date: (DateTime.current + 14)) }
        embargo_length "6 months"
        files_embargoed true
        abstract_embargoed true
        toc_embargoed true

        factory :sixty_day_expiration do
          degree_awarded { Time.zone.today - 2.years }
          embargo { FactoryGirl.create(:embargo, embargo_release_date: (Time.zone.today + 60.days)) }
        end

        factory :seven_day_expiration do
          degree_awarded { Time.zone.today - 2.years }
          embargo { FactoryGirl.create(:embargo, embargo_release_date: (Time.zone.today + 7.days)) }
        end

        factory :tomorrow_expiration do
          degree_awarded { Time.zone.today - 2.years }
          embargo { FactoryGirl.create(:embargo, embargo_release_date: Time.zone.tomorrow) }
        end

        factory :sample_data_with_only_files_embargoed do
          title ["Sample Data With File Embargo: #{FFaker::Book.title}"]
          abstract_embargoed false
          toc_embargoed false
        end
      end
    end
  end
end
