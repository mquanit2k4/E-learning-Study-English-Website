class UserLesson < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  enum status: {incomplete: 0, completed: 1}

  scope :for_course, lambda {|course|
    joins(:lesson).where(lessons: {course_id: course.id})
  }

  scope :for_user_and_course, (lambda do |user, course|
    joins(:lesson).where(user:, lessons: {course_id: course.id})
  end)

  scope :completed_for_user_and_lessons, (lambda do |user, lesson_ids|
    where(user:, lesson_id: lesson_ids, status: :completed)
  end)

  def self.count_for_user_and_lessons user, lesson_ids
    completed_for_user_and_lessons(user, lesson_ids).count
  end
end
