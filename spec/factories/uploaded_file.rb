FactoryBot.define do
  factory :uploaded_file, class: Hyrax::UploadedFile do
    file { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf") }
    user_id { 1 }
    pcdm_use { "supplementary" }

    factory :primary_uploaded_file, traits: [:primary]
    factory :supplementary_uploaded_file, traits: [:supplementary] do
      file { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/miranda/image.tif") }
      description { 'Description of the supplementary file' }
      file_type { 'Image' }
    end

    trait :primary do
      pcdm_use { FileSet::PRIMARY }
    end

    trait :supplementary do
      pcdm_use { FileSet::SUPPLEMENTARY }
    end
  end
end
