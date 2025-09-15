import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list"]

  connect() {
    this.files = [] // mémoire locale
  }

  update() {
    // Nouveaux fichiers sélectionnés
    const newFiles = Array.from(this.inputTarget.files)

    // Cumuler avec ceux déjà en mémoire
    this.files = [...this.files, ...newFiles]

    // Recréer le FileList avec tous les fichiers cumulés
    const dt = new DataTransfer()
    this.files.forEach(file => dt.items.add(file))
    this.inputTarget.files = dt.files

    // Rafraîchir la prévisualisation
    this.renderPreviews()
  }

  renderPreviews() {
    this.listTarget.innerHTML = ""

    this.files.forEach((file, index) => {
      const card = document.createElement("div")
      card.className = "preview-card"

      const img = document.createElement("img")
      img.alt = file.name
      const reader = new FileReader()
      reader.onload = e => (img.src = e.target.result)
      reader.readAsDataURL(file)

      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "remove-btn"
      btn.innerHTML = "🗑️"
      btn.dataset.index = index
      btn.addEventListener("click", this.remove.bind(this))

      card.appendChild(img)
      card.appendChild(btn)
      this.listTarget.appendChild(card)
    })
  }

  remove(e) {
    const index = parseInt(e.currentTarget.dataset.index, 10)
    this.files.splice(index, 1)

    // Recréer la FileList après suppression
    const dt = new DataTransfer()
    this.files.forEach(file => dt.items.add(file))
    this.inputTarget.files = dt.files

    this.renderPreviews()
  }
}
