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
            //'background-color': '#4F46E5', // Indigo color
            'label': 'data(label)',
            'color': '#1F2937',
            'font-size': '12px',
            'text-valign': 'center',
            'text-halign': 'center',
            'width': '30px',
            'height': '30px'
          }
        },
        {
          selector: 'node[active]',
          style: {
            'background-color': 'mapData(strenght, 0, 1, #440154, #fde725)', 
            'width':   'mapData(strenght, 0, 1, 20px, 80px)',
            'height':  'mapData(strenght, 0, 1, 20px, 80px)',
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
       }
      ],
//      layout: {
//        name: 'fcose',
//        quality: 'default',
//        animate: false,

//        nodeRepulsion: 25000,
//        idealEdgeLength: 150,
//        edgeElasticity: 0.1,

//        randomize: true
//      }
      layout: {
        name: 'cose-bilkent',
        // 1. Core Visual Settings
        refresh: 30,             // Number of iterations between consecutive screen redraws
        fit: true,               // Fits the graph viewport to all nodes
        padding: 10,             // Padding around the outside perimeter of the graph
        randomize: true,         // False uses current positions, True generates fresh layouts
  
        // 2. Overlap Prevention (Crucial for mixed sizing)
        nodeDimensionsIncludeLabels: true, // Forces layout to respect text bounds

        // 3. Compact Clustering & Tension Tuning
        // Lower values make edges shorter, pulling nodes tightly together
        idealEdgeLength: function(edge) {
          const sourceStr = parseFloat(edge.source().data('strenght')) || 0;
          const targetStr = parseFloat(edge.target().data('strenght')) || 0;
          const combinedStrength = (sourceStr + targetStr) / 2;

    // Strong central nodes are pulled into tight 40px spans; weak nodes drift out to 90px
    return 90 - (combinedStrength * 50);
  },

  // Divides repulsion forces to regulate spacing density (higher = tighter)
  edgeElasticity: 0.45,
  
  // Baseline repulsion coefficient. Lower numbers compress the graph structure.
  nodeRepulsion: function(node) {
    const strength = parseFloat(node.data('strenght')) || 0;
    // Central hubs get low repulsion (1500) so they can bundle close together
    return 4500 - (strength * 3000); 
  },

  // 4. Physics Engine Stabilities
  gravity: 1.5,            // Global gravity pulling everything toward the screen center
  numIter: 2500,           // Maximum number of iterations to solve placement layout
  animate: 'end',          // 'end' shows the finished map instantly, true shows fluid movement
  animationDuration: 1000
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

    // === THE BLANK CANVAS FIX ===
    // Force a micro-delay to let the Rails layout engine finish painting the box dimensions
    setTimeout(() => {
      if (this.cy) {
        this.cy.resize() // Forces Cytoscape to recalculate its width and height properties
        this.cy.invalidateDimensions() // Wipes out stale 0px cache states

        // Trigger the layout to run explicitly now that dimensions are verified
        this.cy.layout({ 
          name: 'fcose', 
          animate: false 
        }).run() 

        this.cy.fit() // Snaps the graph perfectly into the center of the frame
      }
    }, 50)
  }

  disconnect() {
    if (this.cy) {
      this.cy.destroy() // Clean up instances on Turbo page transitions
    }
  }
}
