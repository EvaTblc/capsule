// app/javascript/controllers/image_preview_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "newImage", "hiddenBag"]

  // Nouvelles images (préviews locales)
  update() {
    const files = Array.from(this.inputTarget.files || []).filter(f => f.type.startsWith("image/"))
    if (!files.length) return this.clearList()

    this.renderPreviews(files)
    this.listTarget.classList.remove("hidden")
    if (this.hasNewImageTarget) this.newImageTarget.textContent = "Ajouter d'autres images"
  }

  renderPreviews(files) {
    this.listTarget.innerHTML = ""
    files.forEach((file, idx) => {
      const card = document.createElement("div")
      card.className = "preview-card"

      const img = document.createElement("img")
      const reader = new FileReader()
      reader.onload = e => (img.src = e.target.result)
      reader.readAsDataURL(file)

      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "remove-btn"
      btn.setAttribute("aria-label", "Retirer cette image")
      btn.innerHTML = "&#128465;" // 🗑️
      btn.dataset.index = String(idx)
      btn.addEventListener("click", this.removeNewAt.bind(this))

      card.appendChild(img)
      card.appendChild(btn)
      this.listTarget.appendChild(card)
    })
  }

  removeNewAt(e) {
    const indexToRemove = Number(e.currentTarget.dataset.index)
    const current = Array.from(this.inputTarget.files || [])
    const kept = current.filter((_, i) => i !== indexToRemove)

    const dt = new DataTransfer()
    kept.forEach(f => dt.items.add(f))
    this.inputTarget.files = dt.files

    kept.length ? this.renderPreviews(kept) : this.clearList()
  }

  clearList() {
    this.listTarget.innerHTML = ""
    this.listTarget.classList.add("hidden")
    if (this.hasNewImageTarget) this.newImageTarget.textContent = "Choisir une image"
  }

  toggleExisting(e) {
    const btn  = e.currentTarget
    const card = btn.closest(".preview-card")
    const id   = btn.dataset.photoId
    if (!id || !card) return

    const selected = card.classList.toggle("to-remove")
    btn.classList.toggle("active", selected)

    // Gère l’input hidden remove_photo_ids[]
    const selector = `input[type="hidden"][name="remove_photo_ids[]"][value="${id}"]`
    const existing = this.hiddenBagTarget?.querySelector(selector)

    if (selected && !existing) {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "remove_photo_ids[]"
      input.value = id
      this.hiddenBagTarget.appendChild(input)
    } else if (!selected && existing) {
      existing.remove()
    }
  }

}
