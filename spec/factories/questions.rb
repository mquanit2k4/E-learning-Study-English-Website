FactoryBot.define do
  factory :question do
    sequence(:content) { |n| "Question #{n} content" }
    question_type { :single_choice }
    association :test
    created_at { Time.current }
    updated_at { Time.current }

    # Create answers using build to satisfy validation
    after(:build) do |question|
      question.answers.build(content: "Correct answer", correct: true)
      question.answers.build(content: "Incorrect answer 1", correct: false)
      question.answers.build(content: "Incorrect answer 2", correct: false)
    end

    trait :with_answers do
      after(:create) do |question|
        create(:answer, :correct, question: question, content: "Correct answer")
        create(:answer, :incorrect, question: question, content: "Incorrect answer 1")
        create(:answer, :incorrect, question: question, content: "Incorrect answer 2")
      end
    end

    trait :multiple_choice do
      question_type { :multiple_choice }

      after(:build) do |question|
        question.answers.clear
        question.answers.build(content: "Correct answer 1", correct: true)
        question.answers.build(content: "Correct answer 2", correct: true)
        question.answers.build(content: "Incorrect answer 1", correct: false)
        question.answers.build(content: "Incorrect answer 2", correct: false)
      end
    end

    trait :single_choice do
      question_type { :single_choice }
    end
  end
end
