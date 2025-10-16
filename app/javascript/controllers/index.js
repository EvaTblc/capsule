import { application } from "controllers/application"

import BarcodeController from "controllers/barcode_controller"
application.register("barcode", BarcodeController)

import CollectionPreviewController from "controllers/collection_preview_controller"
application.register("collection-preview", CollectionPreviewController)

import HelloController from "controllers/hello_controller"
application.register("hello", HelloController)

import HintController from "controllers/hint_controller"
application.register("hint", HintController)

import ImagePreviewController from "controllers/image_preview_controller"
application.register("image-preview", ImagePreviewController)

import PhotoModalController from "controllers/photo_modal_controller"
application.register("photo-modal", PhotoModalController)

import ScannerLoaderController from "controllers/scanner_loader_controller"
application.register("scanner-loader", ScannerLoaderController)

import ToggleController from "controllers/toggle_controller"
application.register("toggle", ToggleController)

import RememberToggleController from "controllers/remember_toggle_controller"
application.register("remember-toggle", RememberToggleController)
