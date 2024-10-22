import SwiftUI

@main
struct GeoCrushApp: App {
    var body: some Scene {
        #if os(visionOS)
        ImmersiveSpace {
            GameView()
        }
        #else
        WindowGroup {
            GameView().ignoresSafeArea()
        }
        #endif
    }
}
