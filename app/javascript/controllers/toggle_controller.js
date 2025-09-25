import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkSearch", "checkPossess", "scan", "addBook", "controls", "oups", "oupsHaveIt", "oupsFindIt", "numberCopies", "displayCopies"]

  connect() {
  }

  toggleCheckbox(event) {
    if ( event.target === this.checkPossessTarget ) {
      this.scanTarget.classList.remove("d-none")
      this.addBookTarget.classList.add("d-none")
      this.checkSearchTarget.style.opacity = "0.7"
      this.checkPossessTarget.style.opacity = "1"
      // this.controlsTarget.classList.add("d-none")

    } else if ( event.target === this.checkSearchTarget ) {
      this.addBookTarget.classList.remove("d-none")
      this.scanTarget.classList.add("d-none")
      this.controlsTarget.classList.add("d-none")
      if ( this.scanTarget.classList.contains("d-none")) {
        this.oupsTarget.classList.remove("d-none");
        this.oupsHaveItTarget.classList.remove("d-none")
      }
    }
  }

  displayInfosCopies() {
    this.displayCopiesTarget.classList.toggle("d-none")
  }
}
