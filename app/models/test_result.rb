class TestResult < ApplicationRecord
  belongs_to :user
  belongs_to :component

  enum status: {passed: 0, failed: 1}

  # Validations
  validates :attempt_number, presence: true
  validates :mark, presence: true

  scope :for_user_and_course, (lambda do |user, course|
    joins(component: {lesson: :course})
      .where(user:, lessons: {course_id: course.id})
      .includes(component: :test)
      .order(:created_at)
  end)
end
