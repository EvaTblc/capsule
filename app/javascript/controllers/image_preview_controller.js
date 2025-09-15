// app/javascript/controllers/image_preview_controller.js
import { Controller } from "@hotwired/stimulus"

// Compresse une image en JPEG
async function compressImage(file, quality = 0.8, maxWidth = 1920, maxHeight = 1080) {
  return new Promise(resolve => {
    const img = new Image()
    img.src = URL.createObjectURL(file)

    img.onload = () => {
      const canvas = document.createElement("canvas")
      let { width, height } = img

      if (width > maxWidth || height > maxHeight) {
        const ratio = Math.min(maxWidth / width, maxHeight / height)
        width *= ratio
        height *= ratio
      }

      canvas.width = width
      canvas.height = height
      canvas.getContext("2d").drawImage(img, 0, 0, width, height)

      canvas.toBlob(
        blob => {
          resolve(new File([blob], file.name, { type: "image/jpeg" }))
        },
        "image/jpeg",
        quality
      )
    }
  })
}

export default class extends Controller {
  static targets = ["input", "list", "hiddenBag"]

  // 🔄 Quand un input file change (caméra ou galerie)
  async update(e) {
    const input = e.target
    let files = Array.from(input.files || []).filter(f => f.type.startsWith("image/"))

    if (!files.length) return

    // Compression en parallèle
    files = await Promise.all(files.map(f => compressImage(f, 0.7)))

    // Fusionner tous les fichiers des inputs (caméra + galerie)
    const allFiles = Array.from(this.inputTargets)
      .flatMap(input => Array.from(input.files || []))
      .concat(files)

    // Remplacer les fichiers de l’input courant par les compressés
    const dt = new DataTransfer()
    files.forEach(f => dt.items.add(f))
    input.files = dt.files

    this.renderPreviews(allFiles)
    this.listTarget.classList.remove("hidden")
  }

  // 🖼️ Affiche les prévisualisations
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
      btn.innerHTML = "🗑️"
      btn.dataset.index = String(idx)
      btn.addEventListener("click", this.removeNewAt.bind(this))

      card.appendChild(img)
      card.appendChild(btn)
      this.listTarget.appendChild(card)
    })
  }

  // ❌ Supprime une image de la liste
  removeNewAt(e) {
    const indexToRemove = Number(e.currentTarget.dataset.index)

    // Fusionner tous les fichiers actuels
    const allFiles = Array.from(this.inputTargets).flatMap(input => Array.from(input.files || []))
    const kept = allFiles.filter((_, i) => i !== indexToRemove)

    // Réinjecter les fichiers conservés dans le premier input
    const dt = new DataTransfer()
    kept.forEach(f => dt.items.add(f))
    this.inputTargets[0].files = dt.files

    kept.length ? this.renderPreviews(kept) : this.clearList()
  }

  // 🔄 Reset
  clearList() {
    this.listTarget.innerHTML = ""
    this.listTarget.classList.add("hidden")
  }

  // ✅ Gère la suppression d’images existantes en mode édition
  toggleExisting(e) {
    const btn = e.currentTarget
    const card = btn.closest(".preview-card")
    const id = btn.dataset.photoId
    if (!id || !card) return

    const selected = card.classList.toggle("to-remove")
    btn.classList.toggle("active", selected)

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
