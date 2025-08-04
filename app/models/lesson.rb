class Lesson < ApplicationRecord
  belongs_to :course
  belongs_to :creator, class_name: User.name, foreign_key: "created_by_id"

  has_many :components, dependent: :destroy
  has_many :user_lessons, dependent: :destroy
end
