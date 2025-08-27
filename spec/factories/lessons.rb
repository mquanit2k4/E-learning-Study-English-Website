FactoryBot.define do
  factory :lesson do
    sequence(:title) { |n| "Lesson Title #{n}" }
    description { "A sample lesson description that meets validation requirements" }
    sequence(:position) { |n| n }
    association :course
    association :creator, factory: :user
    created_at { Time.current }
    updated_at { Time.current }
  end
end
