import SwiftUI
import RealityKit
import ARKit
//=========================================================================
//====================== create pin by button tapped ======================
//=========================================================================
struct ARPin: UIViewRepresentable{
    // Load global varibles
    @Binding var screenSize: CGSize
    @Binding var createdPinEntities : [CreatedPinEntity]
    // !!!! Set the CGPoint of the location indicator (this should derived from the device screen size)
    let indicatorPoint: CGPoint = CGPoint(x: 196.5, y: 436.425)
    // Customized view holder
    @EnvironmentObject var viewModel: ViewModel
    
    // Required function _ makeUIView
    func makeUIView(context: Context) -> ARView {
        // Initialize the AR view
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        // Configure the session for the view holder
        viewModel.configureSession(forView: arView)
        
        // Add "tapRecognizer" to the "arView"
        context.coordinator.arView = arView
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator,
                                                   action: #selector(Coordinator.viewTapped(_:)))
        tapRecognizer.name = "ARView Tap"
        arView.addGestureRecognizer(tapRecognizer)
        
        // Return the "arView"
        return arView
    }
    
    // Required function _ updateUIView
    // Update the "pinIndicator"
    func updateUIView(_ uiView: ARView, context: Context) {
        //============================================================================
        //============================ Lines between Nodes ===========================
        //============================================================================
        // 1. has more than one entity
        // 2. the line has not been drawn yet (has not attached to the last entity yet)
        // 3. the last two entities are on the same surface
        if (createdPinEntities.count > 1) && (createdPinEntities.last!.pinEntity.children.count == 2) && (simd_almost_equal_elements(createdPinEntities[createdPinEntities.count-2].anchorTransformMatrix.getOrientationMatrix(), createdPinEntities.last!.anchorTransformMatrix.getOrientationMatrix(), 0.02)) {
            //================================= [[ Calculate parameters to draw the line ]] =================================
            let position_1 = createdPinEntities.last!.entityTransformMatrix.columns.3
            let position_2 = createdPinEntities[createdPinEntities.count-2].entityTransformMatrix.columns.3
            let difference_x = ( position_2.x-position_1.x ) / 2
            let difference_y = ( position_2.y-position_1.y ) / 2
            let difference_z = ( position_2.z-position_1.z ) / 2
            let distance = sqrt( pow(difference_x*2, 2)+pow(difference_y*2, 2)+pow(difference_z*2, 2) )
            print(distance)
            //===============================================================================================================
            
            //============================================ [[ Create the line ]] ============================================
            // the RGB indicator
            var lineMaterial = SimpleMaterial(color: .red, roughness: 0, isMetallic: false)
            var lineMesh = MeshResource.generateBox(width: difference_x*2, height: Float(0.003), depth: Float(0.003))
            var lineEntity = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
            lineEntity.generateCollisionShapes(recursive: true)
            createdPinEntities.last!.pinEntity.addChild(lineEntity)
            lineEntity.setPosition(SIMD3(difference_x,0,0), relativeTo: lineEntity)
            
            lineMaterial = SimpleMaterial(color: .blue, roughness: 0, isMetallic: false)
            lineMesh = MeshResource.generateBox(width: Float(0.003), height: difference_z*2, depth: Float(0.003))
            lineEntity = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
            lineEntity.generateCollisionShapes(recursive: true)
            createdPinEntities.last!.pinEntity.addChild(lineEntity)
            lineEntity.setPosition(SIMD3(difference_x*2,-difference_z,0), relativeTo: lineEntity)
            
            lineMaterial = SimpleMaterial(color: .green, roughness: 0, isMetallic: false)
            lineMesh = MeshResource.generateBox(width: Float(0.003), height: Float(0.003), depth: difference_y*2)
            lineEntity = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
            lineEntity.generateCollisionShapes(recursive: true)
            createdPinEntities.last!.pinEntity.addChild(lineEntity)
            lineEntity.setPosition(SIMD3(difference_x*2,-difference_z*2,difference_y), relativeTo: lineEntity)
            //===============================================================================================================
        }
    }
    
    class Coordinator: NSObject {
        weak var arView: ARView?
        let parent: ARPin

        init(parent: ARPin) { self.parent = parent }

        @objc func viewTapped(_ gesture: UITapGestureRecognizer) {
            // Get parameters to create entity
            guard let arView,
                  let result = arView.raycast(from: parent.indicatorPoint,
                                              allowing: .existingPlaneGeometry,
                                              alignment: .any).first,
                  let anchor = result.anchor
            else { return }
            
            // Create the pin
            createPin(anchor: anchor, at: result.worldTransform, in: arView)
        }
        
        func createPin(anchor:ARAnchor, at worldTransform:simd_float4x4, in arView:ARView) {
            parent.viewModel.addPin(anchor: anchor,
                                    at: worldTransform,
                                    in: arView,
                                    store_at: &parent.createdPinEntities)
        }
    }

    func makeCoordinator() -> ARPin.Coordinator {
        return Coordinator(parent: self)
    }
}
