FactoryGirl.define do
  factory :etd do
    title ['China and its Minority Population']
    creator ['Eun, Dongwon']
    keyword ['China', 'Minority Population']
    degree ['MS']
    department ['Religion']
    school ['Laney Graduate School']
    subfield ['Ethics and Society']
    partnering_agency ["Does not apply (no collaborating organization)"]
    submitting_type ["Honors Thesis"]
    research_field ['Oncology']
    committee_chair [FactoryGirl.build(:committee_member)]
    committee_members FactoryGirl.build_list(:committee_member, 3)
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    factory :ateer_etd do
      id 'rpj6m'
      title ['Investigating and Developing a Novel Implicit Measurement of Self-Esteem']
      creator ['Teer, Drew']
      keyword ['classical conditioning', 'implict', 'self-esteem']
      submitting_type ["Master's Thesis"]
      # research_field ['Clinical Psychology']
      # research_field_id ['id0622']
      department ['Psychology']
      degree ['MA']
      language ['English']
      committee_chair [
        FactoryGirl.build(:committee_member, name: 'Treadway, Michael T')
      ]
      committee_members [
        FactoryGirl.build(:committee_member, name: 'Craighead, W Edward'),
        FactoryGirl.build(:committee_member, name: 'Manns, Joseph')
      ]
      # How to record embargo?
      # embargoed_until ['2017-08-21']
      # embargo_duration ['Embargoed for 1 year']
      identifier ['ark:/25593/rpj6m']
      # file_format ['application/pdf']
      post_graduation_email ['redacted@example.com']
      # permanent_address ['123 Sesame St, Atlanta, GA 30306, UNITED STATES']
      # pdf ["#{fixture_path}/joey/joey_thesis.pdf"]
      # abstract ['']
      # table_of_contents ['']
    end
  end
end
