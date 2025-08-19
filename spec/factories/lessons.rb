FactoryBot.define do
  factory :lesson do
    sequence(:title) { |n| "Lesson #{n}" }
    description { "A sample lesson description" }
    association :course
    created_at { Time.current }
    updated_at { Time.current }
  end
end
