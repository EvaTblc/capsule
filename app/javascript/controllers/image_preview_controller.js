import { Controller } from "@hotwired/stimulus"

// Compression d’image
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
  static targets = ["master", "list"]

  async addFiles(event) {
    const files = Array.from(event.target.files || [])
    if (!files.length) return

    // ⚡ Mode avatar = single file
    if (this.masterTarget.name === "user[avatar]") {
      const dt = new DataTransfer()
      dt.items.add(files[0]) // garde uniquement le premier
      this.masterTarget.files = dt.files
      this.renderPreviews([files[0]])
      return
    }

    // ⚡ Mode items = multiple files
    const currentFiles = Array.from(this.masterTarget.files || [])
    const merged = [...currentFiles, ...files]

    const dt = new DataTransfer()
    merged.forEach(f => dt.items.add(f))
    this.masterTarget.files = dt.files

    this.renderPreviews(merged)
  }

  renderPreviews(files) {
    this.listTarget.innerHTML = ""
    files.forEach(file => {
      const img = document.createElement("img")
      img.src = URL.createObjectURL(file)
      img.className = "preview-avatar"

      this.listTarget.appendChild(img)
    })
  }

  renderPreviews(files) {
    this.listTarget.innerHTML = ""
    files.forEach((file, idx) => {
      const card = document.createElement("div")
      card.className = "preview-card"

      const img = document.createElement("img")
      img.src = URL.createObjectURL(file)
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
    const current = Array.from(this.masterTarget.files || [])
    const kept = current.filter((_, i) => i !== indexToRemove)

    const dt = new DataTransfer()
    kept.forEach(f => dt.items.add(f))
    this.masterTarget.files = dt.files

    kept.length ? this.renderPreviews(kept) : this.clearList()
  }

  clearList() {
    this.listTarget.innerHTML = ""
  }
}
