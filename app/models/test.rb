class Test < ApplicationRecord
  IMAGE_DISPLAY_SIZE = [300, 200].freeze

  TEST_PERMITTED = %i(name description duration max_attempts).freeze

  has_many :questions, dependent: :destroy
  has_many :components, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :duration, presence: true, numericality: {greater_than: 0}
  validates :max_attempts, presence: true,
numericality: {greater_than_or_equal_to: 0}

  accepts_nested_attributes_for :questions, allow_destroy: true

  scope :recent, ->{order(created_at: :desc)}
  scope :by_name, lambda {|keyword|
    return all if keyword.blank?

    where("name LIKE ?", "%#{sanitize_sql_like(keyword)}%")
  }
end
