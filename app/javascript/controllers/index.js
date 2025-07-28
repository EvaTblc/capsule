// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import ScannerLoaderController from "./scanner_loader_controller"
application.register("scanner-loader", ScannerLoaderController)

import PhotoModalController from "./photo_modal_controller"
application.register("photo-modal", PhotoModalController)
