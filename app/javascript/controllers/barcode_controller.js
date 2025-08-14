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
    window.addEventListener("error", (e) => this.output(`❌ JS: ${e.message}`))
    window.addEventListener("unhandledrejection", (e) => this.output(`❌ Promise: ${e.reason}`))
  }

  async startScan() {
    if (this.running) return
    this.running = true
    this.output("Initialisation caméra…")

    try {
      // 1) iOS: déclenche le prompt permission AVANT ZXing
      await navigator.mediaDevices.getUserMedia({ video: { facingMode: { ideal: "environment" } } })

      // 2) Essai 1 — via constraints (meilleure compat iOS)
      try {
        await this.reader.decodeFromConstraints(
          { video: { facingMode: "environment" } }, // arrière
          this.videoTarget,
          (res, err) => this._onDecode(res, err)
        )
        return
      } catch (_) {
        // continue vers Essai 2
      }

      // 3) Essai 2 — via deviceId (Android/desktop)
      const devices = await this.reader.listVideoInputDevices()
      if (!devices.length) throw new Error("Pas de caméra détectée")
      const back = devices.find(d => /back|rear|environment|arrière/i.test(d.label)) || devices[0]

      this.reader.decodeFromVideoDevice(back.deviceId, this.videoTarget, (res, err) => this._onDecode(res, err))

    } catch (e) {
      this.output(`❌ Caméra: ${e.message}`)
      this.running = false
    }
  }

  _onDecode(res, err) {
    if (!res) return
    const now = Date.now()
    this.lastDecodedAt ||= 0
    if (now - this.lastDecodedAt < 1200) return
    this.lastDecodedAt = now

    const code = res.getText().replace(/\D/g, "")
    if (!code) return
    this.output(`✅ Code détecté: ${code}`)
    this.stopScan()
    this.postToIntake(code)
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
    const ct = r.headers.get("content-type") || ""
    if (!r.ok) {
      const err = ct.includes("json") ? (await r.json()).error : (await r.text()).slice(0,200)
      this.output(`❌ ${r.status} ${err || "Erreur"}`)
      return
    }
  }

  output(text) { if (this.hasOutputTarget) this.outputTarget.textContent = text }
}
