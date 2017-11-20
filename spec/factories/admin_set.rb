FactoryBot.define do
  factory :admin_set do
    id { ActiveFedora::Noid::Service.new.mint }
    title { [] << FFaker::Book.title }
    creator { ["admin_set_owner"] }
  end
end
