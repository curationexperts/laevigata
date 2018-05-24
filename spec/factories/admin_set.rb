FactoryBot.define do
  factory :admin_set do
    id { Noid::Rails::Service.new.mint }
    title { [] << FFaker::Book.title }
    creator { ["admin_set_owner"] }
  end
end
