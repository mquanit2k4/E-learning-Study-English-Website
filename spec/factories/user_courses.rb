FactoryBot.define do
  factory :user_course do
    association :user
    association :course
    enrolment_status { :pending }
    reason { nil }
    created_at { Time.current }
    updated_at { Time.current }

    trait :approved do
      enrolment_status { :approved }
    end

    trait :rejected do
      enrolment_status { :rejected }
      reason { "Course is full" }
    end

    trait :in_progress do
      enrolment_status { :in_progress }
    end

    trait :completed do
      enrolment_status { :completed }
    end
  end
end
