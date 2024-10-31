//
//  CameraManager.swift
//  GeoCrush
//
//  Created by Jose Cruz on 16/10/2024.
//

import RealityKit

class CameraManager {
    private let camera: Entity
    private let root: Entity
    private let rowCount: Int
    private let columnCount: Int
    private let objectSpace: Float = 1.2
    
    init(camera: Entity, root: Entity, rowCount: Int, columnCount: Int) {
        self.camera = camera
        self.root = root
        self.rowCount = rowCount
        self.columnCount = columnCount
    }
    
    func adjustCameraPosition() {
        let totalWidth = Float(rowCount) * objectSpace
        let totalHeight = Float(columnCount) * objectSpace
        let maxDimension = max(totalWidth, totalHeight)
        let cameraDistance = maxDimension * objectSpace + 5
        camera.look(at: [0, 0, 0], from: [0, 0, +cameraDistance], relativeTo: root)
    }
}
