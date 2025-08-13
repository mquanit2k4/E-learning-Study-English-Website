class UserCourse < ApplicationRecord
  belongs_to :user
  belongs_to :course

  enum enrolment_status: {
    pending: 0,
    approved: 1,
    rejected: 2,
    in_progress: 3,
    completed: 4
  }

  ENROLMENT_STATUSES = [
    enrolment_statuses[:approved],
    enrolment_statuses[:in_progress],
    enrolment_statuses[:completed]
  ].freeze

  COURSE_INCLUDES = {
    course: [
      :approved_user_courses,
      {thumbnail_attachment: :blob}
    ]
  }.freeze

  scope :approved_statuses, ->{where(enrolment_status: ENROLMENT_STATUSES)}

  scope :with_course, ->{includes(COURSE_INCLUDES)}

  scope :with_status, (lambda do |status|
    status.present? ? where(enrolment_status: status) : all
  end)

  scope :recent, ->{order(created_at: :desc)}
end
