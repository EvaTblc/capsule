import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "query", "results", "nameField", "sourceField", "sourceIdField",
    "platformsField", "genresField", "releaseDateField", "summaryField", "coverUrlField"
  ]
  static values = {
    searchUrl: String,
    collectionId: String,
    categoryId: String
  }

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)

    const query = this.queryTarget.value.trim()
    if (query.length < 3) {
      this.resultsTarget.innerHTML = ""
      this.resultsTarget.classList.add("d-none")
      return
    }

    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, 500)
  }

  async performSearch(query) {
    try {
      const url = `${this.searchUrlValue}?query=${encodeURIComponent(query)}`
      const response = await fetch(url)
      const data = await response.json()

      if (data.error) {
        this.showError(data.error)
        return
      }

      this.displayResults(data.games)
    } catch (error) {
      console.error("Erreur de recherche:", error)
      this.showError("Erreur lors de la recherche")
    }
  }

  displayResults(games) {
    if (!games || games.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="list-group-item text-muted">
          Aucun jeu trouvé
        </div>
      `
      this.resultsTarget.classList.remove("d-none")
      return
    }

    const html = games.map(game => `
      <a href="#"
         class="list-group-item list-group-item-action"
         data-action="click->game-search#selectGame"
         data-game='${JSON.stringify(game).replace(/'/g, "&#39;")}'>
        <div class="d-flex align-items-center">
          ${game.cover_url ? `<img src="${game.cover_url}" alt="${this.escapeHtml(game.name)}" class="me-3" style="width: 40px; height: 50px; object-fit: cover;">` : ''}
          <div>
            <div class="fw-bold">${this.escapeHtml(game.name)}</div>
            <small class="text-muted">${this.escapeHtml(game.platforms || '')} ${game.release_date ? `(${game.release_date})` : ''}</small>
          </div>
        </div>
      </a>
    `).join('')

    this.resultsTarget.innerHTML = html
    this.resultsTarget.classList.remove("d-none")
  }

  async selectGame(event) {
    event.preventDefault()
    const link = event.currentTarget

    // Récupérer les données stockées dans le dataset
    const gameData = JSON.parse(link.dataset.game)

    this.populateForm(gameData)

    // Fermer les résultats
    this.resultsTarget.classList.add("d-none")
    this.queryTarget.value = ""
  }

  populateForm(game) {
    // Remplir le nom
    if (this.hasNameFieldTarget) {
      this.nameFieldTarget.value = game.name
    }

    // Remplir source et source_id
    if (this.hasSourceFieldTarget) {
      this.sourceFieldTarget.value = "igdb"
    }
    if (this.hasSourceIdFieldTarget) {
      this.sourceIdFieldTarget.value = game.id
    }

    // Remplir les champs metadata individuels
    if (game.metadata) {
      if (this.hasPlatformsFieldTarget && game.metadata.platforms) {
        this.platformsFieldTarget.value = game.metadata.platforms
      }
      if (this.hasGenresFieldTarget && game.metadata.genres) {
        this.genresFieldTarget.value = game.metadata.genres
      }
      if (this.hasReleaseDateFieldTarget && game.metadata.release_date) {
        this.releaseDateFieldTarget.value = game.metadata.release_date
      }
      if (this.hasSummaryFieldTarget && game.metadata.summary) {
        this.summaryFieldTarget.value = game.metadata.summary
      }
      if (this.hasCoverUrlFieldTarget && game.metadata.cover_url) {
        this.coverUrlFieldTarget.value = game.metadata.cover_url
      }
    }

    // Afficher un message de succès
    this.showSuccess(`Jeu "${game.name}" sélectionné !`)
  }

  showError(message) {
    this.resultsTarget.innerHTML = `
      <div class="list-group-item text-danger">
        ${this.escapeHtml(message)}
      </div>
    `
    this.resultsTarget.classList.remove("d-none")
  }

  showSuccess(message) {
    // Créer une alerte Bootstrap temporaire
    const alert = document.createElement('div')
    alert.className = 'alert alert-success alert-dismissible fade show mt-2'
    alert.innerHTML = `
      ${this.escapeHtml(message)}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `
    this.queryTarget.parentElement.appendChild(alert)

    setTimeout(() => alert.remove(), 3000)
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
