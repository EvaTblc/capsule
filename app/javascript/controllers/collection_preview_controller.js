import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    this.updatePreview()
  }

  updatePreview() {
    const collectionName = this.inputTarget.value
    const previewCard = this.element.closest('.preview-card')

    if (collectionName.trim()) {
      this.previewTarget.textContent = `// Nouvelle collection: ${collectionName}`
      this.previewTarget.style.color = "var(--cyber-green)"
      previewCard.classList.add('active')
    } else {
      this.previewTarget.textContent = "// Nouvelle collection: [En attente...]"
      this.previewTarget.style.color = "var(--cyber-gray)"
      previewCard.classList.remove('active')
    }
  }
}