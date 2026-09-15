// app/javascript/controllers/relationship_graph_controller.js
import { Controller } from "@hotwired/stimulus"
import cytoscape from "cytoscape"

import fcose from 'cytoscape-fcose'
cytoscape.use(fcose);


// Connects to data-controller="relationship"
export default class extends Controller {
  static targets = [ "container" ]
  static values = { elements: Array }

  connect() {
    console.log("Collaborations graph controller connected");
    this.cy = cytoscape({
      container: this.containerTarget,
      elements: this.elementsValue,
      style: [
        {
          selector: 'node',
          style: {
            'label': 'data(label)',
            'color': '#ffffff',             // White text color
            'text-outline-color': '#111111', // Heavy dark outline
            'text-outline-width': '2px',    // Thicker outline for maximum contrast

            'font-size': '12px',
            'text-valign': 'center',
            'text-halign': 'center',
            'width': '20px',
            'height': '20px'
          }
        },
        {
          selector: 'node[active]',
          style: {
            'background-color': 'mapData(strength, 0, 1, #e0f2f1, #0076BE)', 
            'border-color': '#ffffff',
            'width':   'mapData(strength, 0, 1, 20px, 40px)',
            'height':  'mapData(strength, 0, 1, 20px, 40px)',
          }
        },
        {
          selector: 'node[!active]',
          style: {
            'background-color': '#d1d5db',
            'color': '#9ca3af'
        }
        },
        {
          selector: 'edge',
          style: {
            'width': 2,
            'line-color': '#2B7CE9',
            'curve-style': 'bezier',
          }
        },
        {
          selector: 'edge[?is_secondary]',
          style: {
            'width': 1,
            'line-color': '#cbd5e1',
            'line-style': 'dashed',
           }
        },
        {
          selector: ".central",
          style: {
            "background-color": "#36669c",
            'border-width': '1px', 
            'border-paint': '#cbd5e1',
            'font-size': '14px',
            'width': '45px',
            'height': '45px'
          }
        }
      ],
      layout: {
        name: 'fcose',
        quality: 'default',
        animate: false,

        nodeRepulsion: 25000,
        idealEdgeLength: 150,
        edgeElasticity: 0.3,
	gravity: 0.1,
	
        randomize: true
      }
    })

    this.popup = document.getElementById("author-popup")
    this.cy.on("tap",(event) => {
      const node = event.target

      if (node.data("active")){
        this.popup.innerHTML = `<div class="card_body">
                                  <h6>${node.data("full_name")} </h6>
                                  <div> ${node.data("orcid")}</div>
                                  <div> Articles: ${node.data("pub_count")}</div>
                                  <div> Collaborations: ${node.data("collab_count")}</div>
                                </div>`
      } else {
        this.popup.innerHTML = `<div class="card_body">
                                  <h6>${node.data("label")} </h6>
                                  <div> No public details for author</div>
                                </div>`
      };
      const graphRect = this.containerTarget.getBoundingClientRect()
      const pos = event.renderedPosition

      this.popup.style.left = `${graphRect.left + window.scrollX + pos.x + 15}px`
      this.popup.style.top = `${graphRect.top + window.scrollY + pos.y + 15}px`
      this.popup.style.display = "block"
    });

    this.cy.on("tap", (event) =>{
      if (event.target === this.cy){
        this.popup.style.display = "none"
      }
    })
  }

  disconnect() {
    if (this.cy) {
      this.cy.destroy() // Clean up instances on Turbo page transitions
    }
  }
}
