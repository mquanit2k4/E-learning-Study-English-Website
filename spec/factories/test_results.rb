FactoryBot.define do
  factory :test_result do
    association :user
    association :test
    association :component
    attempt_number { 1 }
    user_answers { {} }
    score { 0 }
    status { :failed }
    submitted { false }
    created_at { Time.current }
    updated_at { Time.current }

    trait :passed do
      status { :passed }
      score { 80 }
      submitted { true }
    end

    trait :failed do
      status { :failed }
      score { 40 }
      submitted { true }
    end

    trait :submitted do
      submitted { true }
    end
  end
end
