import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "bar"]

  connect() {
    document.addEventListener("turbo:load", () => this.show())
  }

  show() {
    if (!this.hasOverlayTarget || !this.hasBarTarget) return

    this.overlayTarget.classList.remove("scanner-hidden")

    // Force reflow for animation restart
    this.barTarget.offsetWidth

    this.barTarget.classList.remove("animate")
    void this.barTarget.offsetWidth // trigger reflow again
    this.barTarget.classList.add("animate")

    setTimeout(() => {
      this.overlayTarget.classList.add("scanner-hidden")
    }, 800) // durée du scan
  }
}
