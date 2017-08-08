FactoryGirl.define do
  factory :uploaded_file, class: Hyrax::UploadedFile do
    id { ActiveFedora::Noid::Service.new.mint }
    file { "fake_title.pdf" }
    user_id { 1 }
    pcdm_use { "supplementary" }
  end
end
