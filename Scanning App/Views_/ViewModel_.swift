import Foundation
import Combine
import ARKit
import RealityKit

final class ViewModel: NSObject, ObservableObject {
    /// Allow loading to take a minimum amount of time, to ease state transitions
    private static let loadBuffer: TimeInterval = 2
    
    private let entityLoader = EntityLoader()
    private var loadCancellable: AnyCancellable?
    
    private var anchors = [UUID: AnchorEntity]()
    
    @Published var assetsLoaded = false

    func resume() {
        if !assetsLoaded && loadCancellable == nil { loadAssets() }
    }

    func pause() {
        loadCancellable?.cancel()
        loadCancellable = nil
    }
    
    // MARK: - Private methods

    private func loadAssets() {
        let beforeTime = Date().timeIntervalSince1970
        loadCancellable = entityLoader.loadEntity { [weak self] result in
            guard let self else {
                return
            }
            switch result {
                case let .failure(error):
                    print("Failed to load assets \(error)")
                case .success:
                    let delta = Date().timeIntervalSince1970 - beforeTime
                    var buffer = Self.loadBuffer - delta
                    if buffer < 0 {
                        buffer = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + buffer) {
                        self.assetsLoaded = true
                    }
            }
        }
    }
    
    func addPin(anchor: ARAnchor,
                at worldTransform: simd_float4x4,
                in view: ARView,
                store_at createdPinEntities: inout [CreatedPinEntity]) {
        // Create a new pin to place at the tap location
        let pin: Entity
        do {
            pin = try entityLoader.createPin()
        } catch let error {
            print("Failed to create pin: \(error)")
            return
        }
        
        defer {
            // Get translation from transform
            let column = worldTransform.columns.3
            let translation = SIMD3<Float>(column.x, column.y, column.z)
            // Move the pin to the tap location
            pin.setPosition(translation, relativeTo: nil)
                       
            // !!!! Need to optimize
            //      Now I am using the height to check if the plan direction, there should be a better plan
            // Rotate the pin modelEntity by 180 deg around the X axis
            //    if  ( the added pin is on the horizontal anchor )
            //    and ( the height of the anchor is higher than "0.9" )
            //        ( however, the threshold "0.9" should be measured for every app initialization )
            if (abs(worldTransform.columns.1.y) > 0.95) && (column.y > 0.9) {
//                print("DEBUG - Orien : \(pin.orientation)")
                pin.setOrientation(simd_quatf(angle: .pi, axis: [1,0,0]), relativeTo: pin)
//                print("DEBUG - Orien : \(pin.orientation)")
//                print("*********************************DEBUG - Trans")
            }
            
            // Add the created pinEntity and transformation matricies to the array
            createdPinEntities.append(CreatedPinEntity(createdPinEntity: pin, anchorTransformMatrix: anchor.transform, entityTransformMatrix: worldTransform))
        }
        
        // If there is not already an anchor here, create one
        guard let anchorEntity = anchors[anchor.identifier] else {
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(pin)
            view.scene.addAnchor(anchorEntity)
            anchors[anchor.identifier] = anchorEntity
            return
        }
        // Add the pin to the existing anchor
        anchorEntity.addChild(pin)
    }
    
    func configureSession(forView arView: ARView) {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        arView.session.delegate = self
    }
}

extension ViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        anchors.forEach { anchor in
            guard let anchorEntity = self.anchors[anchor.identifier] else {
                return
            }
            // Lost an anchor, remove the AnchorEntity from the Scene
            anchorEntity.scene?.removeAnchor(anchorEntity)
            self.anchors.removeValue(forKey: anchor.identifier)
        }
    }
}
