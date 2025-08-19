FactoryBot.define do
  factory :test do
    sequence(:name) { |n| "Test #{n}" }
    description { "A sample test description that meets the minimum length requirement of ten characters" }
    duration { 30 }
    max_attempts { 3 }
    created_at { Time.current }
    updated_at { Time.current }
  end
end
