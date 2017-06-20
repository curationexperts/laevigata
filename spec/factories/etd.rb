FactoryGirl.define do
  factory :etd do
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
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    factory :ateer_etd do
      before(:create) do |etd|
        # etd.ordered_members << FactoryGirl.create(:public_pdf,
        #                                           content: File.open("#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf", "r"),
        #                                           id: ActiveFedora::Noid::Service.new.mint, user: user)
      end

      id { ActiveFedora::Noid::Service.new.mint }
      depositor 'ateer@fake.com'
      title ['Investigating and Developing a Novel Implicit Measurement of Self-Esteem']
      creator ['Teer, Drew']
      keyword ['classical conditioning', 'implict', 'self-esteem']
      submitting_type ["Master's Thesis"]
      research_field ['Clinical Psychology']
      school ['Laney Graduate School']
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
      # file_format ['application/pdf']
      post_graduation_email ['redacted@example.com']
      # permanent_address ['123 Sesame St, Atlanta, GA 30306, UNITED STATES']
    end
  end
end
