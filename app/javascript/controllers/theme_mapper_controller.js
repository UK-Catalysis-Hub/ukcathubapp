import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme-mapper"
export default class extends Controller {
  connect(){
    //console.log("IssueMapperController is connected!");
  }

  moveTheme(event) {
    const fromList = this.element.querySelector(`#${event.target.dataset.from}`);
    const toList = this.element.querySelector(`#${event.target.dataset.to}`);

    Array.from(fromList.selectedOptions).forEach(option => {
      toList.appendChild(option);
    });

    this.validateSelection();
  }

  validateSelection() {
    const assignedList = this.element.querySelector('#assigned_themes');
    const themesList = document.getElementById('theme_ids');
    var selectedIds = Array.from(assignedList.options).map(option => option.value);
    themesList.value = selectedIds.join(","); 
  }
}
