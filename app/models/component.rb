class Component < ApplicationRecord
  belongs_to :lesson
  belongs_to :test, optional: true
  belongs_to :word, optional: true

  has_many :user_words, dependent: :destroy
  has_many :test_results, dependent: :destroy

  enum component_type: {word: 0, test: 1, paragraph: 2}

  scope :sorted_by_index, ->{order(:index_in_lesson)}
end
