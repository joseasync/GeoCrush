import Combine
import SwiftUI
import RealityKit

struct GameView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> GameViewController {
        return GameViewController()
    }

    func updateNSViewController(_ uiViewController: GameViewController, context: Context) {
    }
}

class GameViewController: NSViewController {
    private let arView: ARView
    private let gameController: GameController
    private var cancellables: Set<AnyCancellable>

    init() {
        let camera = PerspectiveCamera()
        let rootAnchor = AnchorEntity()
        let arView = ARView()
        arView.scene.addAnchor(rootAnchor)
        rootAnchor.addChild(camera)
        let gameController = GameController(root: rootAnchor, camera: camera, assetLoader: AssetLoader(), rowCount: 8, columnCount: 8)
        self.arView = arView
        self.gameController = gameController
        self.cancellables = []

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.view.addSubview(self.arView)
        self.arView.translatesAutoresizingMaskIntoConstraints = false
        self.arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.arView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.arView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        self.arView.scene.subscribe(to: SceneEvents.Update.self, { [weak self] event in
            guard let self else {
                return
            }
            gameController.tick(deltaTime: event.deltaTime)
        }).store(in: &cancellables)

        let click = NSClickGestureRecognizer(target: self, action: #selector(onClickGesture))
        self.arView.addGestureRecognizer(click)
    }

    @objc
    func onClickGesture(_ click: NSClickGestureRecognizer) {
        guard let ray = arView.ray(through: click.location(in: arView)) else {
            return
        }

        guard let hit = arView.scene.raycast(origin: ray.origin, direction: ray.direction).first else {
            return
        }

        gameController.didPressEntity(hit.entity)
    }
}
