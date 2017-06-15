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
    research_field ['0992']
    committee_chair [FactoryGirl.build(:committee_member)]
    committee_members FactoryGirl.build_list(:committee_member, 3)
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end
end
