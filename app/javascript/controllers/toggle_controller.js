import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["name", "button", "div"]

  connect() {
  }

  toggle(event) {
    event.stopPropagation();
    this.divTarget.classList.toggle("d-none")
    this.buttonTarget.classList.toggle("d-none")
    this.nameTarget.classList.toggle("d-none")
  }

}
