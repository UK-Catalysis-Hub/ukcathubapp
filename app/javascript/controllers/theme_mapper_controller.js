import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme-mapper"
//export default class extends Controller {
//  connect() {
//  }
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

    //this.validateSelection();
  }

  validateSelection() {
    const assignedList = this.element.querySelector('#assigned_issues');
    // const submitButton = this.element.querySelector('#submit_button');
    // submitButton.disabled = assignedList.options.length === 0;
  }
}
