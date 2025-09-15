// app/javascript/controllers/hint_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { key: String }

  connect(){
    const k = this.keyValue || "robot_hint"
    if (localStorage.getItem(k) === "1") this.element.remove()
  }

  hide(){
    const k = this.keyValue || "robot_hint"
    localStorage.setItem(k, "1")
    this.element.remove()
  }
}
