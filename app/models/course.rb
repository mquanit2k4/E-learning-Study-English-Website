class Course < ApplicationRecord
  IMAGE_DISPLAY_SIZE = [300, 200].freeze
  DESCRIPTION_PREVIEW_LENGTH = 100

  attr_accessor :course_admin_ids

  belongs_to :creator, class_name: User.name, foreign_key: "created_by_id"

  after_save :assign_admin_managers_from_ids, if: ->{course_admin_ids.present?}

  MINIMUM_DURATION = 0
  MINIMUM_TITLE_LENGTH = 5
  MAX_TITLE_LENGTH = 100

  COURSE_PERMITTED = [
    :title, :description, :duration,
    {course_admin_ids: []},
    {lessons_attributes: %i(id title content _destroy)}
  ].freeze
  COURSE_PRELOAD = [:creator, :lessons, :admins].freeze
  COURSE_INCLUDES = [:lessons, :admins, :users].freeze

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
  scope :by_title, lambda {|title|
    return all if title.blank?

    where("title LIKE ?", "%#{title}%")
  }

  validates :title, presence: true,
length: {minimum: MINIMUM_TITLE_LENGTH, maximum: MAX_TITLE_LENGTH},
uniqueness: true
  validates :description, presence: true
  validates :duration, presence: true,
numericality: {greater_than: MINIMUM_DURATION}

  accepts_nested_attributes_for :admin_course_managers, :lessons,
                                allow_destroy: true

  private

  def assign_admin_managers_from_ids
    assign_admin_managers(course_admin_ids)
  end

  def assign_admin_managers admin_ids
    return if admin_ids.blank?

    admin_course_managers.destroy_all

    admin_ids.compact_blank.uniq.each do |admin_id|
      manager = admin_course_managers.create(user_id: admin_id)

      unless manager.persisted?
        errors.add(t(".assign_admin_failed", admin_id:, course_id: id))
        raise ActiveRecord::Rollback
      end
    end
  end
end
