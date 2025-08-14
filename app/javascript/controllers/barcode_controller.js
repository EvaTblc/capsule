// app/javascript/controllers/barcode_controller.js
import { Controller } from "@hotwired/stimulus"
import { BrowserMultiFormatReader, DecodeHintType, BarcodeFormat } from "https://cdn.jsdelivr.net/npm/@zxing/library@0.21.2/+esm"

export default class extends Controller {
  static values = { intakeUrl: String, newUrl: String }
  static targets = ["video", "output"]

  connect() {
    const hints = new Map()
    hints.set(DecodeHintType.POSSIBLE_FORMATS, [BarcodeFormat.EAN_13, BarcodeFormat.EAN_8, BarcodeFormat.UPC_A])
    this.reader = new BrowserMultiFormatReader(hints)
    this.running = false
    this.lastDecodedAt = 0
  }

  async startScan() {
    if (this.running) return
    this.running = true
    this.output("Initialisation caméra…")
    try {
      const devices = await this.reader.listVideoInputDevices()
      if (!devices.length) throw new Error("Pas de caméra détectée")
      const back = devices.find(d => /back|rear|environment|arrière/i.test(d.label)) || devices[0]
      this.reader.decodeFromVideoDevice(back.deviceId, this.videoTarget, (res) => {
        if (!res) return
        const now = Date.now()
        if (now - this.lastDecodedAt < 1200) return // anti-doublon
        this.lastDecodedAt = now

        const code = res.getText().replace(/\D/g, "")
        if (!code) return
        this.output(`✅ Code détecté: ${code}`)
        this.stopScan()
        this.postToIntake(code)
      })
    } catch (e) {
      this.output(`❌ ${e.message}`); this.running = false
    }
  }

  stopScan() {
    if (!this.running) return
    this.reader.reset()
    this.running = false
  }

  async postToIntake(code) {
    try {
      const r = await fetch(this.intakeUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content
        },
        body: JSON.stringify({ barcode: code })
      })

      const ct = r.headers.get("content-type") || ""
      if (!r.ok) {
        const err = ct.includes("json") ? (await r.json()).error : (await r.text()).slice(0,200)
        this.output(`❌ ${r.status} ${err || "Erreur"}`)
        return
      }
      const payload = ct.includes("json") ? await r.json() : {}

      // ➜ redirection vers /new avec prefill (base64) via **newUrlValue**
      const prefill = btoa(JSON.stringify(payload))
      const url = `${this.newUrlValue}?prefill=${encodeURIComponent(prefill)}`
      if (window.Turbo) { Turbo.visit(url) } else { window.location.href = url }
    } catch (e) {
      this.output(`❌ Réseau: ${e.message}`)
    }
  }

  output(text) { if (this.hasOutputTarget) this.outputTarget.textContent = text }
}
