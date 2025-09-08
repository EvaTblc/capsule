import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-book"
export default class extends Controller {
  connect() {
    console.log("Add Book Controller");
  }
}
