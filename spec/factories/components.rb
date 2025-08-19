FactoryBot.define do
  factory :component do
    component_type { :test }
    association :lesson
    association :test
    index_in_lesson { 1 }

    trait :test_type do
      component_type { :test }
      association :test
    end

    trait :word_type do
      component_type { :word }
      association :word
    end

    trait :paragraph_type do
      component_type { :paragraph }
      content { "Sample paragraph content" }
    end
  end
end
