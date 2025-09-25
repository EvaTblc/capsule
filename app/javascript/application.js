// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import "bootstrap"
import "@popperjs/core"
import { Application } from "@hotwired/stimulus"

window.__BarcodeStimulusApp__ ||= Application.start()
// You'll need to import BarcodeController as well if you use it
// import BarcodeController from "./controllers/barcode_controller"
// window.__BarcodeStimulusApp__.register("barcode", BarcodeController)

