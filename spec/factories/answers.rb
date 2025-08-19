FactoryBot.define do
  factory :answer do
    sequence(:content) { |n| "Answer #{n}" }
    correct { false }
    association :question

    trait :correct do
      correct { true }
    end

    trait :incorrect do
      correct { false }
    end
  end
end
