FactoryGirl.define do
  factory :uploaded_file, class: Hyrax::UploadedFile do
    user
    file { File.open("#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf", "r") }
  end
end
