FactoryBot.define do
  factory :uploaded_file, class: Hyrax::UploadedFile do
    file { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf") }
    user_id { 1 }
    pcdm_use { FileSet::SUPPLEMENTARY }

    factory :primary_uploaded_file, traits: [:primary]

    factory :remote_uploaded_file do
      browse_everything_url { 'http://example.com/remote/file.pdf' }
    end

    factory :supplementary_uploaded_file, traits: [:supplementary] do
      file { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/miranda/image.tif") }
      description { 'Description of the supplementary file' }
      file_type { 'Image' }
    end

    factory :uploaded_image_file, traits: [:supplementary] do
      file { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/miranda/image.tif") }
      title { FFaker::Animal.common_name }
      description { "portrait" }
      file_type { 'Image' }
    end

    factory :uploaded_data_file, traits: [:supplementary] do
      file { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/miranda/rural_clinics.zip") }
      title { "Rural Clinics in Georgia" }
      description { "GIS shapefile showing rural clinics" }
      file_type { 'Dataset' }
    end

    trait :primary do
      pcdm_use { FileSet::PRIMARY }
    end

    trait :supplementary do
      pcdm_use { FileSet::SUPPLEMENTARY }
    end
  end
end
