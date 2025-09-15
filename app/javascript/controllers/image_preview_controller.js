import { Controller } from "@hotwired/stimulus"

// Compresse une image en JPEG
function compressImage(file, quality = 0.7, maxWidth = 1920, maxHeight = 1080) {
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
          resolve(new File([blob], file.name.replace(/\.[^.]+$/, ".jpg"), { type: "image/jpeg" }))
        },
        "image/jpeg",
        quality
      )
    }
  })
}

export default class extends Controller {
  static targets = ["input", "list"]

  async update(e) {
    const input = e.target
    let files = Array.from(input.files || [])

    if (!files.length) return this.clearList()

    // 🔄 Compression avant upload
    const compressedFiles = await Promise.all(
      files.map(f => compressImage(f))
    )

    // Injecter les fichiers compressés dans l’input
    const dt = new DataTransfer()
    compressedFiles.forEach(f => dt.items.add(f))
    input.files = dt.files

    // ✅ Utiliser les fichiers compressés pour prévisualisation
    this.renderPreviews(compressedFiles)
  }

  renderPreviews(files) {
    this.listTarget.innerHTML = ""
    files.forEach((file, idx) => {
      const card = document.createElement("div")
      card.className = "preview-card"

      const img = document.createElement("img")
      img.src = URL.createObjectURL(file) // ← preview fiable
      card.appendChild(img)

      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "remove-btn"
      btn.innerHTML = "🗑️"
      btn.dataset.index = String(idx)
      btn.addEventListener("click", this.removeAt.bind(this))

      card.appendChild(btn)
      this.listTarget.appendChild(card)
    })
  }

  removeAt(e) {
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
  }
}
