FactoryBot.define do
  factory :committee_member do
    initialize_with { etd.committee_members.build }
    transient { etd { FactoryBot.build(:etd) } }

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
