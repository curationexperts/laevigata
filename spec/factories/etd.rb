FactoryGirl.define do
  factory :etd do
    title ['China and its Minority Population']
    creator ['Eun, Dongwon']
    keyword ['China', 'Minority Population']
    degree ['Bachelor of Arts with Honors']
    department ['Department of Russian and East Asian Languages and Cultures']
    school ['Emory College of Arts and Sciences']
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end
end
