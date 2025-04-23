import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme-mapper"
export default class extends Controller {
  connect(){
    console.log("IssueMapperController is connected!");
  }
  moveTheme(event) {
    console.log("move theme called!");
    const fromList = this.element.querySelector(`#${event.target.dataset.from}`);
    const toList = this.element.querySelector(`#${event.target.dataset.to}`);

    Array.from(fromList.selectedOptions).forEach(option => {
      toList.appendChild(option);
    });

    this.validateSelection();
  }

  validateSelection() {
    console.log("Validating Selection")
    const assignedList = this.element.querySelector('#assigned_themes');
    const themesList = document.getElementById('theme_ids');
    var selectedIds = Array.from(assignedList.options).map(option => option.value);
    console.log(selectedIds.join(","));
    themesList.value = selectedIds.join(","); 
    // const submitButton = this.element.querySelector('#submit_button');
    // submitButton.disabled = assignedList.options.length === 0;
  }
}
