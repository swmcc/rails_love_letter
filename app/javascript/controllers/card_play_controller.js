import { Controller } from "@hotwired/stimulus"

// Progressive enhancement for the play-card forms: the form works without
// JavaScript; this just disables the submit button until the required
// target/guess pickers are filled in.
export default class extends Controller {
  static targets = ["target", "guess"]

  connect() {
    this.element.addEventListener("change", () => this.validate())
    this.validate()
  }

  validate() {
    const button = this.element.querySelector("button[type=submit], button:not([type])")
    if (!button) return

    const required = []
    if (this.hasTargetTarget) required.push(this.targetTarget)
    if (this.hasGuessTarget) required.push(this.guessTarget)

    const incomplete = required.some((select) => !select.value)
    button.disabled = incomplete
    button.classList.toggle("opacity-50", incomplete)
    button.classList.toggle("cursor-not-allowed", incomplete)
  }
}
