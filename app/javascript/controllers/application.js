import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Enable debug mode in development to see controller errors
application.debug = true
window.Stimulus   = application

export { application }
