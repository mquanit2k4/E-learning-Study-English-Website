FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :user }
    birthday { 20.years.ago }
    gender { :male }

    trait :admin do
      role { :admin }
    end

    trait :user_role do
      role { :user }
    end
  end
end
