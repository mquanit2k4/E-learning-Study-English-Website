FactoryBot.define do
  factory :word do
    sequence(:content) { |n| "word#{n}" }
    sequence(:meaning) { |n| "meaning#{n}" }
    word_type { "noun" }
  end
end
