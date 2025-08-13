// app/javascript/controllers/barcode_controller.js
import { Controller } from "@hotwired/stimulus"
import { BrowserMultiFormatReader, DecodeHintType, BarcodeFormat } from "https://cdn.jsdelivr.net/npm/@zxing/library@0.21.2/+esm"

export default class extends Controller {
  static values = { intakeUrl: String, newUrl: String }
  static targets = ["video","output"]

  connect() {
    const hints = new Map()
    hints.set(DecodeHintType.POSSIBLE_FORMATS, [BarcodeFormat.EAN_13, BarcodeFormat.EAN_8, BarcodeFormat.UPC_A])
    this.reader = new BrowserMultiFormatReader(hints)
    this.running = false
  }

  async startScan() {
    if (this.running) return
    this.running = true
    try {
      const devices = await this.reader.listVideoInputDevices()
      if (!devices.length) throw new Error("Pas de caméra détectée")
      const deviceId = devices[0].deviceId

      this.reader.decodeFromVideoDevice(deviceId, this.videoTarget, (res) => {
        if (!res) return
        const code = res.getText().replace(/\D/g,"")
        this.stopScan()
        this.postToIntake(code)
      })
    } catch (e) { this.output(`❌ ${e.message}`); this.running = false }
  }

  stopScan() { if (this.running) { this.reader.reset(); this.running = false } }

  async postToIntake(code) {
    try {
      const r = await fetch(this.intakeUrlValue, {
        method: "POST",
        headers: { "Content-Type":"application/json", "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content },
        body: JSON.stringify({ barcode: code })
      })
      const json = await r.json()
      if (!r.ok) return this.output(`❌ ${r.status} ${json.error || "Erreur"}`)

      // On fabrique un petit objet de préremplissage
      const prefill = {
        name: json.name,
        barcode: json.barcode,
        type: json.type,                 // ex. "BookItem"
        source: json.source,
        source_id: json.source_id,
        metadata: json.metadata || {}
      }
      const qp = new URLSearchParams({ prefill: btoa(JSON.stringify(prefill)) })
      const url = `${this.newUrlValue}?${qp.toString()}`

      // Redirection vers le formulaire “new” pré-rempli
      if (window.Turbo) { Turbo.visit(url) } else { window.location.href = url }
    } catch (e) { this.output(`❌ Réseau: ${e.message}`) }
  }

  output(t){ if (this.hasOutputTarget) this.outputTarget.textContent = t }
}
