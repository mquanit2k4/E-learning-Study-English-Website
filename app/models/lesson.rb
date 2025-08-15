class Lesson < ApplicationRecord
  belongs_to :course
  belongs_to :creator, class_name: User.name, foreign_key: "created_by_id"

  has_many :components, dependent: :destroy
  has_many :user_lessons, dependent: :destroy

  scope :with_user_lessons_for, (lambda do |user|
    includes(:user_lessons).where(user_lessons: {user_id: [user.id, nil]})
  end)
end
