FactoryBot.define do
  factory :course do
    sequence(:title) { |n| "Course #{n}" }
    description { "A sample course description" }
    duration { 0 }
    association :creator, factory: :user
    created_at { Time.current }
    updated_at { Time.current }
  end
end
