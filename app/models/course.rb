class Course < ApplicationRecord
  IMAGE_DISPLAY_SIZE = [300, 200].freeze

  belongs_to :creator, class_name: User.name, foreign_key: "created_by_id"

  has_many :lessons, dependent: :destroy
  has_many :user_courses, dependent: :destroy
  has_many :users, through: :user_courses
  has_many :admin_course_managers, dependent: :destroy
  has_many :admins, through: :admin_course_managers, source: :user

  has_many :approved_user_courses,
           ->{approved_statuses},
           class_name: UserCourse.name,
           dependent: :destroy

  has_one_attached :thumbnail

  scope :recent, ->{order(created_at: :desc)}
  scope :with_users, ->{includes(:approved_user_courses)}
end
