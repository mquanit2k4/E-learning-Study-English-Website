import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["answers", "answerTemplate", "questionType", "correctInput"]
  static values = { questionType: String }

  connect() {
    this.updateAnswerInputType()
  }

  questionTypeChanged() {
    this.questionTypeValue = this.questionTypeTarget.value
    this.updateAnswerInputType()
  }

  addAnswer(event) {
    event.preventDefault()
    console.log("Add answer clicked!")
    const content = this.answerTemplateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.answersTarget.insertAdjacentHTML("beforeend", content)
    this.updateAnswerInputType()
  }

  removeAnswer(event) {
    event.preventDefault()
    const wrapper = event.target.closest(".answer-field")
    if (wrapper) {
      if (wrapper.dataset.newRecord === "true") {
        wrapper.remove()
      } else {
        const destroyInput = wrapper.querySelector('input[name*="_destroy"]')
        destroyInput.value = "1"
        wrapper.style.display = "none"
      }
    }
  }

  updateAnswerInputType() {
    const isSingleChoice = this.questionTypeValue === "single_choice"

    this.correctInputTargets.forEach(input => {
      if (isSingleChoice) {
        if (input.dataset.behavior === "radio-input") {
          input.style.display = "inline-block"
        } else if (input.dataset.behavior === "checkbox-input") {
          input.style.display = "none"
          input.checked = false;
        }
      } else { // Multiple choice
        if (input.dataset.behavior === "checkbox-input") {
          input.style.display = "inline-block"
        } else if (input.dataset.behavior === "radio-input") {
          input.style.display = "none"
          input.checked = false;
        }
      }
    })
  }

  toggleCheckbox(event) {
  }

  toggleRadio(event) {
    this.correctInputTargets.forEach(input => {
      if (input.dataset.behavior === "radio-input" && input !== event.target) {
        input.checked = false;
      }
    });
  }
}
