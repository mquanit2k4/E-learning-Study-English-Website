class Question < ApplicationRecord
  belongs_to :test
  has_many :answers, dependent: :destroy

  enum question_type: {single_choice: 0, multiple_choice: 1}

  accepts_nested_attributes_for :answers, allow_destroy: true

  validates :content, :question_type, presence: true

  validate :at_least_one_correct_answer

  private

  def at_least_one_correct_answer
    return if answers.any?(&:correct)

    errors.add(:base,
               I18n.t("admin.questions.at_least_one_correct_answer_required"))
  end
end
