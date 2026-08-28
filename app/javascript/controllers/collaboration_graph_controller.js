// app/javascript/controllers/relationship_graph_controller.js
import { Controller } from "@hotwired/stimulus"
import cytoscape from "cytoscape"

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
            'background-color': '#4F46E5', // Indigo color
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
            'background-color': '#2563eb', // Indigo color
            'color': '#111827'
          }
        },
        {
          selector: 'node[!active]',
          style: {
            'background-color': '#d1d5db', // Indigo color
            'color': '#9ca3af'
        }
        },
        {
          selector: 'edge',
          style: {
            'width': 2,
            'line-color': '#2B7CE9',
            'curve-style': 'bezier',
            //'label': 'data(weight)',
            //'font-size': '10px',
            //'color': '#6B7280'
          }
        },
        {
          selector: 'edge[?is_secondary]',
          style: {
            'width': 1,
            'line-color': '#cbd5e1',
            'line-style': 'dashed',
            //'label': 'data(weight)',
            //'font-size': '10px',
            //'color': '#6B7280'
          }
       }
      ],
      layout: {
        name: 'cose', // Built-in force-directed physics layout
        animate: true,
        
        // === THE PHYSICS FIXES FOR SPREADING ===
        nodeRepulsion: (node) => 204800,  // Increase this massively (Default is ~400000)
        idealEdgeLength: (edge) => 100,    // Force edges to stretch out further (Default is ~10)
        edgeElasticity: (edge) => 32,      // Lower numbers make edges less stiff, letting them stretch
        nestingFactor: 1.2,                // Helps push secondary connections further apart
        gravity: 1,                        // Set lower to let peripheral nodes drift outwards (Default is ~80)
  
        // === OVERLAP PREVENTION ===
        nodeOverlap: 200,                   // Extra padding space around nodes
        componentSpacing: 100,             // Distance between disconnected clusters
        coolingFactor: 0.95,               // Slower cooling means the physics run longer to find space
        numIter: 1000                      // Gives the engine more time to calculate the spread
      } 
    })
    
  
    this.cy.nodes().forEach(node => {
      // 1. Get the number of connected edges (Degree Centrality)
      const degree = node.degree(); 

      // 2. Map the degree to a dynamic pixel size (e.g., base size of 20px + 4px per edge)
      // Clamp it to a maximum of 80px so it doesn't take over the screen
      const dynamicSize = Math.min(20 + (degree * 2), 80);

      // 3. Apply the style dynamically to this specific node instance
      if (node.data("active")){
        node.style({
          'width': `${dynamicSize}px`,
          'height': `${dynamicSize}px`,

          // Optional: Make heavily connected nodes a deeper/more vibrant color
          'background-color': degree > 5 ? '#1d4ed8' : '#60a5fa', 

          // Make the text font larger for important nodes
          'font-size': degree > 5 ? '16px' : '12px'
        });
      }else{
        node.style({
          'width': `${dynamicSize}px`,
          'height': `${dynamicSize}px`
          });
      };
    });  
    this.popup = document.getElementById("author-popup")
    this.cy.on("tap",(event) => {
      const node = event.target
 
     
      if (node.data("active")){
        this.popup.innerHTML = `<div class="card_body">
                             <p><strong>${node.data("full_name")} </strong></p>
                             <p> ${node.data("orcid")}</p>
                           </div>`
      } else {
        this.popup.innerHTML = `<div class="card_body">
                             <p><strong>${node.data("label")} </strong></p>
                             <p> No public details for author</p>
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
