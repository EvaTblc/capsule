import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkSearch", "checkPossess", "scan", "addBook"]

  connect() {

  }

  toggleCheckbox(event) {
    console.log(event.target === this.checkPossessTarget);
    if ( event.target === this.checkPossessTarget ) {
      this.scanTarget.classList.remove("d-none")
      this.addBookTarget.classList.add("d-none")
      this.checkSearchTarget.style.opacity = "0.7"
      this.checkPossessTarget.style.opacity = "1"
    } else if ( event.target === this.checkSearchTarget ) {
      this.addBookTarget.classList.remove("d-none")
      this.scanTarget.classList.add("d-none")
      this.checkPossessTarget.style.opacity = "0.7"
      this.checkSearchTarget.style.opacity = "1"
    }
  }

}
