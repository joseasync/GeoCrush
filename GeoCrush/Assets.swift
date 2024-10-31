import RealityKit

enum AssetType: String, CaseIterable {
    case red, yellow, blue, green
}

class AssetLoader {
    @MainActor
    func load(_ asset: AssetType) async -> Entity {
        let entity: Entity
        switch asset {
        case .red:
            entity = ModelEntity(mesh: .generateSphere(radius: 0.5), materials: [SimpleMaterial(color: .red, isMetallic: false)])
            entity.name = "red"
        case .yellow:
            entity = ModelEntity(mesh: .generateBox(size: 1.0), materials: [SimpleMaterial(color: .yellow, isMetallic: false)])
            entity.name = "yellow"
        case .blue:
            entity = ModelEntity(mesh: .generateSphere(radius: 0.5), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
            entity.name = "blue"
        case .green:
            entity = ModelEntity(mesh: .generateBox(size: 1.0), materials: [SimpleMaterial(color: .green, isMetallic: false)])
            entity.name = "green"
        }
        entity.generateCollisionShapes(recursive: false)

        #if os(visionOS)
        entity.components.set(InputTargetComponent())
        entity.components.set(HoverEffectComponent())
        #endif

        // Simulating loading times
        try? await Task.sleep(for: .seconds(.random(in: 0.1...0.3)))

        return entity
    }
}

