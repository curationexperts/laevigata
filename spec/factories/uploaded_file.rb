FactoryBot.define do
  factory :uploaded_file, class: Hyrax::UploadedFile do
    file { "fake_title.pdf" }
    user_id { 1 }
    pcdm_use { "supplementary" }

    factory :primary_uploaded_file, traits: [:primary]
    factory :supplementary_uploaded_file, traits: [:supplementary]

    trait :primary do
      pcdm_use { FileSet::PRIMARY }
    end

    trait :supplementary do
      pcdm_use { FileSet::SUPPLEMENTARY }
    end
  end
end
