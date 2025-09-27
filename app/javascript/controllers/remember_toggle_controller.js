import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "hiddenField"]

  connect() {
    this.updateButtonState()
  }

  toggle() {
    const isActive = this.buttonTarget.dataset.toggle === "true"
    const newState = !isActive

    this.buttonTarget.dataset.toggle = newState.toString()
    this.hiddenFieldTarget.value = newState ? "1" : "0"

    this.updateButtonState()
  }

  updateButtonState() {
    const isActive = this.buttonTarget.dataset.toggle === "true"

    if (isActive) {
      this.buttonTarget.classList.add("active")
      this.buttonTarget.classList.remove("inactive")
    } else {
      this.buttonTarget.classList.add("inactive")
      this.buttonTarget.classList.remove("active")
    }
  }
}