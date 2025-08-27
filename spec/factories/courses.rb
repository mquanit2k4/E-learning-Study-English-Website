FactoryBot.define do
  factory :course do
    sequence(:title) { |n| "Course Title #{n}" }
    description { "A sample course description that meets validation requirements" }
    duration { 30 }
    association :creator, factory: :user
    created_at { Time.current }
    updated_at { Time.current }
  end
end
