// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import "bootstrap"
import "@popperjs/core"

window.__BarcodeStimulusApp__ ||= Application.start()
window.__BarcodeStimulusApp__.register("barcode", BarcodeController)

