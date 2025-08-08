module User::TestResultsHelper
  SELECTED_CLASS = "selected".freeze
  CORRECT_CLASS = "correct".freeze
  SINGLE_CHOICE = "single_choice".freeze
  FILLED = "filled".freeze
  CHECKED = "checked".freeze

  def answer_status_class question_data, answer
    is_correct = question_data["correct_answer_ids"].include?(answer.id)
    is_selected = question_data["selected_answer_ids"].include?(answer.id)

    classes = []
    classes << SELECTED_CLASS if is_selected
    classes << CORRECT_CLASS if is_correct

    classes.join(" ")
  end

  def should_show_result_icon? question_data, answer
    is_correct = question_data["correct_answer_ids"].include?(answer.id)
    is_selected = question_data["selected_answer_ids"].include?(answer.id)

    is_selected || is_correct
  end

  def get_result_icon question_data, answer
    is_correct = question_data["correct_answer_ids"].include?(answer.id)
    is_selected = question_data["selected_answer_ids"].include?(answer.id)

    if is_selected && !is_correct
      content_tag(:i, "", class: "glyphicon glyphicon-remove text-danger")
    else
      content_tag(:i, "", class: "glyphicon glyphicon-ok text-success")
    end
  end

  def radio_checkbox_class question_data, answer, question_type
    is_selected = question_data["selected_answer_ids"].include?(answer.id)

    if question_type == SINGLE_CHOICE
      is_selected ? FILLED : ""
    else
      is_selected ? CHECKED : ""
    end
  end
end
