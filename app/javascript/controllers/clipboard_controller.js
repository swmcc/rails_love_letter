import { Controller } from "@hotwired/stimulus"

// Copies the game code to the clipboard and confirms briefly on the button.
export default class extends Controller {
  static targets = ["source", "button"]

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.textContent.trim()).then(() => {
      const original = this.buttonTarget.textContent
      this.buttonTarget.textContent = "Copied!"
      setTimeout(() => { this.buttonTarget.textContent = original }, 1500)
    })
  }
}
