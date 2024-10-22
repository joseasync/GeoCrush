import Foundation
import RealityKit

class GameController {
    private let root: Entity
    private let cameraManager: CameraManager
    private let boardManager: BoardManager
    private let entityManager: EntityManager
    private var isProcessing: Bool = false
    
    init(root: Entity, camera: Entity, assetLoader: AssetLoader, rowCount: Int, columnCount: Int) {
        self.root = root        
        self.cameraManager = CameraManager(camera: camera, root: root, rowCount: rowCount, columnCount: columnCount)
        self.entityManager = EntityManager(root: root, assetLoader: assetLoader, rowCount: rowCount, columnCount: columnCount)
        self.boardManager = BoardManager(entityManager: entityManager, rowCount: rowCount, columnCount: columnCount)
        setupGame()
    }
    
    private func setupGame() {
        Task { @MainActor in
            await entityManager.populateBoard()
            cameraManager.adjustCameraPosition()
        }
    }
    
    func tick(deltaTime: TimeInterval) {
    }
    
    @MainActor
    func didPressEntity(_ entity: Entity) {
        guard !isProcessing else { return }
        isProcessing = true
        Task{
            await boardManager.handleEntityPress(entity)
            isProcessing = false
        }
    }
}
