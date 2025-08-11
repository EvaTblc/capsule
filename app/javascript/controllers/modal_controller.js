import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "content"]

  connect() {
    const frame = this.contentTarget.querySelector("turbo-frame#modal_content")
    if (frame && frame.innerHTML.trim() !== "") {
      this.element.classList.remove("hidden")
    }
  }

  close() {
    this.element.classList.add("hidden")
    const frame = this.contentTarget.querySelector("turbo-frame#modal_content")
    if (frame) frame.innerHTML = ""
  }
}
