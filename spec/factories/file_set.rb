# spec/factories/file_set.rb
FactoryBot.define do
  factory :file_set do
    transient do
      user { FactoryBot.create(:user) }
      content { nil }
    end
    after(:build) do |fs, evaluator|
      fs.apply_depositor_metadata evaluator.user.user_key
    end

    after(:create) do |file, evaluator|
      if evaluator.content
        Hydra::Works::UploadFileToFileSet.call(file, evaluator.content)
      end
    end

    trait :public do
      read_groups { ["public"] }
    end

    trait :registered do
      read_groups { ["registered"] }
    end

    factory :primary_file_set do
      pcdm_use { FileSet::PRIMARY }
    end

    factory :supplemental_file_set do
      pcdm_use { FileSet::SUPPLEMENTARY }
    end

    factory :public_pdf do
      transient do
        id { "fixturepdf" }
      end
      initialize_with { new(id: id) }
      read_groups { ["public"] }
      resource_type { ["Dissertation"] }
      subject { %w[lorem ipsum dolor sit amet] }
      title { ["fake_document.pdf"] }
      before(:create) do |fs|
        fs.title = ["Fake PDF Title"]
      end
    end
    factory :public_mp3 do
      transient do
        id { "fixturemp3" }
      end
      initialize_with { new(id: id) }
      subject { %w[consectetur adipisicing elit] }
      title { ["Test Document MP3.mp3"] }
      read_groups { ["public"] }
    end
    factory :public_wav do
      transient do
        id { "fixturewav" }
      end
      initialize_with { new(id: id) }
      resource_type { ["Audio", "Dataset"] }
      read_groups { ["public"] }
      title { ["Fake Wav File.wav"] }
      subject { %w[sed do eiusmod tempor incididunt ut labore] }
    end
  end
end
