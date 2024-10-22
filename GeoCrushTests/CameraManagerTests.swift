//
//  CameraManagerTests.swift
//  GeoCrush
//
//  Created by Jose Cruz on 17/10/2024.
//


import XCTest
import RealityKit
@testable import GeoCrush

class CameraManagerTests: XCTestCase {
    
    var camera: Entity!
    var root: Entity!
    var cameraManager: CameraManager!
    
    override func setUpWithError() throws {
        camera = Entity()
        root = Entity()
    }

    override func tearDownWithError() throws {
        camera = nil
        root = nil
    }
    
    func testAdjustCameraPosition() {
        let rowCount = 4
        let columnCount = 3
        cameraManager = CameraManager(camera: camera, root: root, rowCount: rowCount, columnCount: columnCount)
        
        cameraManager.adjustCameraPosition()
        
        let expectedWidth = Float(rowCount) * 1.2
        let expectedHeight = Float(columnCount) * 1.2
        let maxDimension = max(expectedWidth, expectedHeight)
        let expectedCameraDistance = maxDimension * 1.2 + 5
        
        XCTAssertEqual(camera.position, SIMD3<Float>(0, 0, -expectedCameraDistance))
    }
}
