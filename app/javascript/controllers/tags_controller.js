import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tagsContainer"]

  connect() {
    console.log("✅ Tags controller connected")
  }

  addTag(event) {
    event.preventDefault()
    let value = this.inputTarget.value.trim()
    if (!value) return

    // sanitize
    value = value.replace(/</g, "&lt;").replace(/>/g, "&gt;")

    const tag = document.createElement("span")
    tag.className = "bg-indigo-100 text-indigo-700 px-3 py-1 rounded-full flex items-center gap-2"
    tag.innerHTML = `
      ${value}
      <button type="button" data-action="tags#removeTag" class="text-indigo-700 font-bold">×</button>
      <input type="hidden" name="user[skills_list][]" value="${value}">
    `
    this.tagsContainerTarget.appendChild(tag)
    this.inputTarget.value = ""
  }

  removeTag(event) {
    const tag = event.target.closest("span")
    if (tag) tag.remove()
  }
}
