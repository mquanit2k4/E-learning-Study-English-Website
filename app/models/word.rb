class Word < ApplicationRecord
  has_many :components, dependent: :destroy

  enum word_type: {
    noun: 0,
    pronoun: 1,
    verb: 2,
    adjective: 3,
    adverb: 4,
    preposition: 5,
    conjunction: 6,
    interjection: 7
  }

  # Validations
  validates :content, presence: true
  validates :meaning, presence: true
  validates :word_type, presence: true, inclusion: {in: word_types.keys}

  # Scopes
  scope :by_type, ->(word_type){where(word_type:)}
  scope :recent, ->{order(created_at: :desc)}

  scope :by_content, (lambda do |query|
    return all if query.blank?

    where("content LIKE ?", "%#{query}%")
  end)

  scope :by_time, lambda {|filter_time|
    case filter_time
    when "today"
      where("created_at >= ?", Time.zone.now.beginning_of_day)
    when "last_7_days", "last_30_days"
      days = Settings.word.filter_days[filter_time].to_i
      where("created_at >= ?", days.days.ago.beginning_of_day)
    else
      all
    end
  }
end
