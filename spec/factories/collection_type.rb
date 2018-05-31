FactoryBot.define do
  factory :collection_type, class: Hyrax::CollectionType do
    sequence(:title)      { |n| "Collection Type #{n}" }
    sequence(:machine_id) { |n| "collection_type_#{n}" }
  end
end
