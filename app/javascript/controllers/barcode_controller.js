import { Controller } from "@hotwired/stimulus"
import { BrowserMultiFormatReader, DecodeHintType, BarcodeFormat } from "https://cdn.jsdelivr.net/npm/@zxing/library@0.21.2/+esm"

export default class extends Controller {
  static values = { intakeUrl: String, newUrl: String }
  static targets = ["video", "output"]

  connect() {
    try {
      const hints = new Map()
      hints.set(DecodeHintType.POSSIBLE_FORMATS, [BarcodeFormat.EAN_13, BarcodeFormat.EAN_8, BarcodeFormat.UPC_A])
      this.reader = new BrowserMultiFormatReader(hints)
      this.running = false
      this.lastDecodedAt = 0

      this.output("[barcode] connect OK")   // 👈 visible dans la page
      window.addEventListener("error", (e) => this.output(`❌ JS: ${e.message}`))
      window.addEventListener("unhandledrejection", (e) => this.output(`❌ Promise: ${e.reason}`))
    } catch (e) {
      this.output(`❌ connect error: ${e.message}`)
    }
  }

  async startScan() {
    this.output("[barcode] startScan clicked")   // 👈 trace le clic
    if (this.running) return
    this.running = true
    this.output("Initialisation caméra…")
    try {
      await navigator.mediaDevices.getUserMedia({ video: { facingMode: { ideal: "environment" } } })
      try {
        await this.reader.decodeFromConstraints(
          { video: { facingMode: "environment" } },
          this.videoTarget,
          (res, err) => this._onDecode(res, err)
        )
        return
      } catch (_) {}

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
    this.output("[barcode] stopScan clicked")
    if (!this.running) return
    this.reader.reset()
    this.running = false
  }

  async postToIntake(code) {
    try {
      this.output(`➡️ POST intake avec code: ${code}`)
      const r = await fetch(this.intakeUrlValue, {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content || ""
        },
        body: JSON.stringify({ barcode: code })
      })

      this.output(`⬅️ HTTP ${r.status}`)
      const ct = (r.headers.get("content-type") || "").toLowerCase()
      if (!ct.includes("application/json")) {
        const txt = await r.text()
        this.output(`⚠️ Réponse non-JSON (${ct || "unknown"})\n${txt.slice(0,400)}…`)
        if (/sign_in|log in|csrf/i.test(txt)) { window.location.href = r.url; return }
        window.location.href = this.newUrlValue
        return
      }

      const payload = await r.json()
      if (!r.ok) { this.output(`❌ ${r.status} ${payload?.error || "Erreur"}`); return }

      const prefill = btoa(JSON.stringify(payload))
      const url = `${this.newUrlValue}?prefill=${encodeURIComponent(prefill)}`
      this.output(`➡️ Redirection vers ${url}`)
      if (window.Turbo) { Turbo.visit(url) } else { window.location.href = url }
    } catch (e) {
      this.output(`❌ Réseau/JS: ${e.message}`)
    }
  }

  async decodeFile(event) {
    const file = event.target.files[0]
    if (!file) return
    const url = URL.createObjectURL(file)
    const img = document.createElement("img")
    img.src = url
    img.style.display = "none"
    document.body.appendChild(img)
    try {
      const reader = new BrowserMultiFormatReader()
      const result = await reader.decodeFromImage(img)
      const code = result.getText().replace(/\D/g, "")
      if (!code) { this.output("❌ Aucun code détecté dans l’image"); return }
      this.output(`✅ Code détecté (image) : ${code}`)
      await this.postToIntake(code)
    } catch (e) {
      this.output(`❌ Impossible de lire le code dans l’image`)
      console.error(e)
    } finally {
      URL.revokeObjectURL(url)
      img.remove()
    }
  }

  output(text) { if (this.hasOutputTarget) this.outputTarget.textContent = String(text) }
}
