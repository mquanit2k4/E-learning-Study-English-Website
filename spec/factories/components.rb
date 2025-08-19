FactoryBot.define do
  factory :component do
    sequence(:title) { |n| "Component #{n}" }
    component_type { :lesson }
    association :lesson

    trait :test do
      component_type { :test }
      association :test
    end

    trait :lesson do
      component_type { :lesson }
    end
  end
end
