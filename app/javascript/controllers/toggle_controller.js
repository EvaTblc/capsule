import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkSearch", "checkPossess", "scan", "addBook", "controls", "oups", "oupsFindIt", "numberCopies", "displayCopies"]

  connect() {
  }

  toggleCheckbox(event) {
    const button = event.currentTarget;
    const targetName = button.dataset.toggleTarget;

    if (targetName === "checkPossess") {
      // Mode POSSESS: afficher le scanner
      this.scanTarget.classList.remove("d-none")
      if (this.hasAddBookTarget) {
        this.addBookTarget.classList.add("d-none")
      }
      // Cacher les boutons de sélection de mode
      if (this.hasControlsTarget) {
        this.controlsTarget.classList.add("d-none")
      }

      // Auto-start barcode scanner après un petit délai pour que la vidéo soit visible
      if (button.dataset.barcodeAutoStart === "true") {
        setTimeout(() => {
          const barcodeController = this.application.getControllerForElementAndIdentifier(this.element, "barcode")
          if (barcodeController) {
            barcodeController.startScan()
          }
        }, 100)
      }

    } else if (targetName === "checkSearch") {
      // Mode SEARCH: afficher le formulaire d'ajout
      if (this.hasAddBookTarget) {
        this.addBookTarget.classList.remove("d-none")
      }
      // Arrêter le scanner s'il est en cours avant de cacher
      const barcodeController = this.application.getControllerForElementAndIdentifier(this.element, "barcode")
      if (barcodeController && barcodeController.running) {
        barcodeController.stopScan()
      }
      this.scanTarget.classList.add("d-none")
      // Cacher les boutons de sélection de mode
      if (this.hasControlsTarget) {
        this.controlsTarget.classList.add("d-none")
      }
    }
  }

  switchMode(event) {
    const button = event.currentTarget;
    const targetMode = button.dataset.toggleTarget;

    // Arrêter le scanner s'il est en cours
    const barcodeController = this.application.getControllerForElementAndIdentifier(this.element, "barcode")
    if (barcodeController && barcodeController.running) {
      barcodeController.stopScan()
    }

    // Simuler un clic sur le bouton du mode cible
    const targetButton = this.element.querySelector(`[data-toggle-target="${targetMode}"]`)
    if (targetButton && !targetButton.classList.contains('switch-mode-btn')) {
      // Créer un event simulé avec l'attribut auto-start pour POSSESS
      if (targetMode === "checkPossess") {
        targetButton.dataset.barcodeAutoStart = "true"
      }
      const simulatedEvent = {
        currentTarget: targetButton
      }
      this.toggleCheckbox(simulatedEvent)
    }
  }

  displayInfosCopies() {
    this.displayCopiesTarget.classList.toggle("d-none")
  }
}
