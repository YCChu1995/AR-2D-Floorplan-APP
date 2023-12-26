import Foundation
import Combine
import RealityKit
import ARKit

class PinEntity: Entity {
    var model: Entity?
    
    static var loadAsync: AnyPublisher<PinEntity, Error> {
//        return Entity.loadAsync(named: "Pin.usdc")
        return Entity.loadAsync(named: "Pin_Small.usdc")
//        return Entity.loadAsync(named: "Sphere_Small.usdc")
            .map { loadedPin -> PinEntity in
                let pin = PinEntity()
                loadedPin.name = "Pin"
                pin.model = loadedPin
                return pin
            }
            .eraseToAnyPublisher()
    }
}

final class CreatedPinEntity {
    var pinEntity: Entity
    var anchorTransformMatrix: simd_float4x4
    var entityTransformMatrix: simd_float4x4
    
    init(createdPinEntity: Entity, anchorTransformMatrix: simd_float4x4, entityTransformMatrix: simd_float4x4) {
        self.pinEntity = createdPinEntity
        self.anchorTransformMatrix = anchorTransformMatrix
        self.entityTransformMatrix = entityTransformMatrix
    }
}
