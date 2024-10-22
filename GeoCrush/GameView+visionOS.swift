import Combine
import SwiftUI
import RealityKit

struct GameView: View {
    @State var sceneUpdateSubscription: EventSubscription? = nil

    @State var gameController: GameController
    @State var root: Entity
    @State var camera: Entity

    init() {
        let root = Entity()
        let camera = Entity()
        let gameController = GameController(root: root, camera: camera, assetLoader: AssetLoader(), rowCount: 10, columnCount: 10)
        self.gameController = gameController
        self._root = State(wrappedValue: root)
        self._camera = State(wrappedValue: camera)
    }

    var body: some View {
        RealityView { content in
            let world = Entity()
            world.addChild(root)
            world.addChild(camera)
            content.add(world)
            world.position = [0, 1.5, 0]
            world.scale = [0.1, 0.1, 0.1]
            sceneUpdateSubscription = content.subscribe(to: SceneEvents.Update.self) { event in
                gameController.tick(deltaTime: event.deltaTime)
                root.transform = Transform(matrix: camera.transform.matrix.inverse)
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { tap in
            gameController.didPressEntity(tap.entity)
        })
    }
}
