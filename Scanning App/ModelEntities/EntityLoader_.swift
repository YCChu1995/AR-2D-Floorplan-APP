import Foundation
import Combine
import RealityKit

class EntityLoader {
    typealias LoadCompletion = (Result<PinEntity, Error>) -> Void
    
    private var loadCancellable: AnyCancellable?
    private var pinEntity: PinEntity?

    func loadEntity(completion: @escaping LoadCompletion) -> AnyCancellable? {
        guard let pinEntity else {
            loadCancellable = PinEntity.loadAsync.sink { result in
                if case let .failure(error) = result {
                    print("Failed to load PinEntity: \(error)")
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] pinEntity in
                guard let self else {
                    return
                }
                self.pinEntity = pinEntity
                completion(.success(pinEntity))
            }
            return loadCancellable
        }
        completion(.success(pinEntity))
        return loadCancellable
    }
    
    func createPin() throws -> Entity {
        guard let pin = pinEntity?.model
        else {
            throw EntityLoaderError.entityNotLoaded
        }
        return pin.clone(recursive: true)
    }
}

enum EntityLoaderError: Error {
    case entityNotLoaded
}
