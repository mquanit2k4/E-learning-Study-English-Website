module User::WordsHelper
  def search_field_options
    [
      [t(".search_fields.all"), :all],
      [t(".search_fields.content"), :content],
      [t(".search_fields.meaning"), :meaning]
    ]
  end

  def status_options
    [
      [t(".status_all"), :all],
      [t(".status_learned"), :learned],
      [t(".status_not_learned"), :not_learned]
    ]
  end

  def word_type_options
    [
      [t(".all_word_types"), :all],
      [t(".word_types.noun"), :noun],
      [t(".word_types.pronoun"), :pronoun],
      [t(".word_types.verb"), :verb],
      [t(".word_types.adjective"), :adjective],
      [t(".word_types.adverb"), :adverb],
      [t(".word_types.preposition"), :preposition],
      [t(".word_types.conjunction"), :conjunction],
      [t(".word_types.interjection"), :interjection],
      [t(".word_types.other"), :other]
    ]
  end

  def sort_options
    [
      [t(".sort_options.alphabetical"), :alphabetical],
      [t(".sort_options.alphabetical_desc"), :alphabetical_desc],
      [t(".sort_options.newest"), :newest],
      [t(".sort_options.oldest"), :oldest],
      [t(".sort_options.word_type"), :word_type]
    ]
  end

  def badge_class word_type
    case word_type.to_sym
    when :noun      then "label-primary"
    when :verb      then "label-info"
    when :adjective then "label-success"
    when :adverb    then "label-warning"
    else "label-default"
    end
  end
end
