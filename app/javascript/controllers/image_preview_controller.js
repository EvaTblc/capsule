import { Controller } from "@hotwired/stimulus"

// Gère:
// - l'aperçu des nouvelles images sélectionnées (et suppression locale)
// - le marquage des photos existantes à supprimer (hidden inputs)

export default class extends Controller {
  static targets = ["input", "list", "newImage", "hiddenBag"]

  // ---- Nouvelles images (input file) ----
  update() {
    const files = Array.from(this.inputTarget.files || []).filter(f => f.type.startsWith("image/"))
    if (!files.length) return this.clearList()

    this.renderNewPreviews(files)
    this.listTarget.classList.remove("hidden")
    if (this.hasNewImageTarget) this.newImageTarget.textContent = "Ajouter d'autres images"
  }

  renderNewPreviews(files) {
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

    // Reconstruit la FileList sans le fichier cliqué
    const dt = new DataTransfer()
    kept.forEach(f => dt.items.add(f))
    this.inputTarget.files = dt.files

    // Re-render
    if (kept.length) {
      this.renderNewPreviews(kept)
    } else {
      this.clearList()
    }
  }

  clearList() {
    this.listTarget.innerHTML = ""
    this.listTarget.classList.add("hidden")
    if (this.hasNewImageTarget) this.newImageTarget.textContent = "Choisir une image"
  }

  // ---- Photos existantes (côté serveur) ----
  // bouton: <button data-action="click->image-preview#toggleExisting" data-photo-id="...">
  toggleExisting(e) {
    const btn = e.currentTarget
    const photoId = btn.dataset.photoId
    if (!photoId) return

    const selected = btn.classList.toggle("to-remove")

    // badge visuel
    const badge = btn.querySelector(".badge")
    if (badge) badge.textContent = selected ? "À supprimer" : "Suppr."

    // ajoute/retire un input hidden remove_photo_ids[]
    const selector = `input[type="hidden"][name="remove_photo_ids[]"][value="${photoId}"]`
    const existing = this.hiddenBagTarget.querySelector(selector)

    if (selected && !existing) {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "remove_photo_ids[]"
      input.value = photoId
      this.hiddenBagTarget.appendChild(input)
    } else if (!selected && existing) {
      existing.remove()
    }
  }
}
