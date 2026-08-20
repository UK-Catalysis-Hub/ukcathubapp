import { Controller } from "@hotwired/stimulus"
import cytoscape from "cytoscape"
import fcose from "cytoscape-fcose"

cytoscape.use(fcose)
// Connects to data-controller="collaborationgraph"
export default class extends Controller {
  static values ={
    graph: Object
  }
  
  connect() {
    console.log("Collaborations graph controller connected")
    console.log(this.graphValue)
    this.cy = cytoscape({
      container: this.element,
      
      elements: [
        ...this.graphValue.nodes,
        ...this.graphValue.edges
      ],
      
      style: [
        {
          selector: "node",
          style: {
            label: "data(label)",
            "background-color": "#2563eb"
          }
        },
        {
          selector: "edge",
          style: {
            width: "mapData(weight,1,20,1,8)"
          }
        },
        {
          selector: ".central",
          style: {
            "background-color": "#dc2626",
            width: 40,
            height: 40
          }
        }
      ],
      
      layout: {
        name: "fcose"
      }
    })
  }
}
