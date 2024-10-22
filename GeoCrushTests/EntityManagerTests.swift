//
//  EntityManagerTests.swift
//  GeoCrush
//
//  Created by Jose Cruz on 17/10/2024.
//
import XCTest
import RealityKit
@testable import GeoCrush

// Mock AssetLoader
class MockAssetLoader: AssetLoader {
    var entities: [Entity] = []
    
    override func load(_ asset: Asset) async -> Entity {
        let entity = Entity()
        entities.append(entity)
        return entity
    }
}

class EntityManagerTests: XCTestCase {
    
    var rootEntity: Entity!
    var assetLoader: MockAssetLoader!
    var entityManager: EntityManager!
    
    override func setUpWithError() throws {
        rootEntity = Entity()
        assetLoader = MockAssetLoader()
        entityManager = EntityManager(root: rootEntity, assetLoader: assetLoader, rowCount: 4, columnCount: 4)
    }
    
    override func tearDown() {
        rootEntity = nil
        assetLoader = nil
        entityManager = nil
    }
    
    func testPopulateBoard() async {
        
        await entityManager.populateBoard()        
        let totalEntities = 4 * 4 // 4 rows, 4 columns
        XCTAssertEqual(rootEntity.children.count, totalEntities)
    }
    
    func testGetEntityAt() async {
        
        await entityManager.populateBoard()
        
        let entityInfo = entityManager.getEntityAt(column: 2, row: 1)
        
        XCTAssertNotNil(entityInfo)
        XCTAssertEqual(entityInfo?.row, 1)
    }
    
    func testFindEntityInColumns() async {
        
        await entityManager.populateBoard()
        guard let targetEntity = entityManager.getEntityAt(column: 3, row: 2)?.entity else {
            XCTFail("Failed to retrieve entity")
            return
        }
        
        let result = await entityManager.findEntityInColumns(targetEntity)
        
        XCTAssertEqual(result?.0, 3)
        XCTAssertEqual(result?.1, 2)
    }
    
    func testRemoveMatches() async {
        
        await entityManager.populateBoard()
        let entityToRemove = entityManager.getEntityAt(column: 0, row: 2)?.entity
        
        await entityManager.removeMatches([(entity: entityToRemove!, column: 0, row: 2)])
        
        let shiftedEntity = entityManager.getEntityAt(column: 0, row: 2)?.entity
        XCTAssertFalse(rootEntity.children.contains(entityToRemove!))
        XCTAssertNotEqual(entityToRemove, shiftedEntity)
    }
}
