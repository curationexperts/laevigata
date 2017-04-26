FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password "12345678"
    password_confirmation "12345678"

    transient do
      # Allow for custom groups when a user is instantiated.
      # @example FactoryGirl.create(:user, groups: 'admin')
      groups []
    end

    factory :admin do
      groups ['admin']
    end

    trait :guest do
      guest true
    end
  end
end
