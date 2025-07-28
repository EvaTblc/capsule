import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "image"]
  static values = {
    url: String
  }

  show(event) {
    const imageUrl = event.currentTarget.dataset.photoModalUrlValue
    this.imageTarget.src = imageUrl
    this.overlayTarget.classList.remove("hidden")
  }

  hide() {
    this.overlayTarget.classList.add("hidden")
    this.imageTarget.src = ""
  }
}
