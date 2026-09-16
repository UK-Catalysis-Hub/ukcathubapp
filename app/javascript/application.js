// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"
import "chartkick/chart.js"

document.addEventListener("turbo:before-fetch-response", (event) => {
  const response = event.detail.fetchResponse.response;
  
  if (response.status === 429) {
    event.preventDefault(); // Disconnects Turbo from replacing your view with a blank error state
    
    // Proactively show a localized toast warning or alert
    alert("Calculations are processing! Please wait a moment before changing filters.");
  }
});
