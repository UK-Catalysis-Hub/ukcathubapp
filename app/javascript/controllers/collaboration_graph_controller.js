// app/javascript/controllers/relationship_graph_controller.js
import { Controller } from "@hotwired/stimulus"
import cytoscape from "cytoscape"

// Connects to data-controller="relationship"
export default class extends Controller {
  static targets = [ "container" ]
  static values = { elements: Array }

  connect() {
    console.log("Collaborations graph controller connected")
    this.cy = cytoscape({
      container: this.containerTarget,
      elements: this.elementsValue,
      style: [
        {
          selector: 'node',
          style: {
            'background-color': '#4F46E5', // Indigo color
            'label': 'data(label)',
            'color': '#1F2937',
            'font-size': '12px',
            'text-valign': 'center',
            'text-halign': 'right',
            'width': '30px',
            'height': '30px'
          }
        },
        {
          selector: 'edge',
          style: {
            'width': 2,
            'line-color': '#9CA3AF',
            'target-arrow-color': '#9CA3AF',
            //'target-arrow-shape': 'triangle',
            'curve-style': 'bezier',
            'label': 'data(relationship)',
            'font-size': '10px',
            'color': '#6B7280'
          }
        }
      ],
      layout: {
        name: 'null'
        name: 'cose', // Built-in force-directed physics layout
        animate: true,
        nodeRepulsion: function( node ){ return 2048; },
        idealEdgeLength: function( edge ){ return 64; }
        
        // === THE PHYSICS FIXES FOR SPREADING ===
        nodeRepulsion: (node) => 2048000,  // Increase this massively (Default is ~400000)
        idealEdgeLength: (edge) => 100,    // Force edges to stretch out further (Default is ~10)
        edgeElasticity: (edge) => 32,      // Lower numbers make edges less stiff, letting them stretch
        nestingFactor: 1.2,                // Helps push secondary connections further apart
        gravity: 1,                        // Set lower to let peripheral nodes drift outwards (Default is ~80)
  
        // === OVERLAP PREVENTION ===
        nodeOverlap: 20,                   // Extra padding space around nodes
        componentSpacing: 100,             // Distance between disconnected clusters
        coolingFactor: 0.95,               // Slower cooling means the physics run longer to find space
        numIter: 1000                      // Gives the engine more time to calculate the spread

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
          name: 'cose', 
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
