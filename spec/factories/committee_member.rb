FactoryGirl.define do
  factory :committee_member do
    name ["Lastname, Firstname"]
    affiliation ['Emory University']
    netid ['jdoe']
  end
  # factory :non_emory_committee_member do
  #   sequence(:name) { |n| ["Lastname, Firstname#{n}"] }
  #   affiliation ['University of Victoria']
  #   netid [nil]
  # end
end
