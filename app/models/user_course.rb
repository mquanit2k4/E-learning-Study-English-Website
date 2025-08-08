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

  scope :approved_statuses, ->{where(enrolment_status: ENROLMENT_STATUSES)}
end
