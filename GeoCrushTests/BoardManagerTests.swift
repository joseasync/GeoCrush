//
//  BoardManagerTests.swift
//  GeoCrush
//
//  Created by Jose Cruz on 17/10/2024.
//

import XCTest
import RealityKit
@testable import GeoCrush

class MockEntityManager: EntityManager {
    var entities = [(entity: Entity, column: Int, row: Int)]()
    var removeMatchesCalled = false
    var moveDownEntitiesCalled = false
    var findEntityInColumnsResult: (Int, Int)?
    
    override func findEntityInColumns(_ entity: Entity) async -> (Int, Int)? {
        return findEntityInColumnsResult
    }
    
    override func moveDownEntitiesInColumn(columnIndex column: Int) async  {
        moveDownEntitiesCalled = true
    }
    
    override func removeMatches(_ entities: [(entity: Entity, column: Int, row: Int)]) async {
        removeMatchesCalled = true
    }
}

class BoardManagerTests: XCTestCase {
    
    var mockEntityManager: MockEntityManager!
    var boardManager: BoardManager!
    
    override func setUpWithError() throws {
        mockEntityManager = MockEntityManager(root: Entity(), assetLoader: MockAssetLoader(), rowCount: 4, columnCount: 4)
        boardManager = BoardManager(entityManager: mockEntityManager, rowCount: 4, columnCount: 4)
    }
    
    override func tearDownWithError() throws {
        mockEntityManager = nil
        boardManager = nil
    }
    
    func testHandleEntityPressRemovesEntity() async {
        let pressedEntity = await Entity()
        mockEntityManager.findEntityInColumnsResult = (2, 3)
        await boardManager.handleEntityPress(pressedEntity)
        XCTAssertTrue(mockEntityManager.moveDownEntitiesCalled)
    }
    
    func testHandleEntityPressEntityNotFound() async {
        let pressedEntity = await Entity()
        mockEntityManager.findEntityInColumnsResult = nil
        await boardManager.handleEntityPress(pressedEntity)
        XCTAssertFalse(mockEntityManager.moveDownEntitiesCalled)
    }
    
    func testValidateAllTilesRemovesMatches() async {
        let matchingEntity1 = await Entity()
        matchingEntity1.name = "red"
        let matchingEntity2 = await Entity()
        matchingEntity2.name = "red"
        let matchingEntity3 = await Entity()
        matchingEntity3.name = "red"
        
        mockEntityManager.entities = [
            (entity: matchingEntity1, column: 0, row: 0),
            (entity: matchingEntity2, column: 1, row: 0),
            (entity: matchingEntity3, column: 2, row: 0)
        ]
        
        await boardManager.handleEntityPress(matchingEntity1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            XCTAssertTrue(self.mockEntityManager.removeMatchesCalled)
        }
    }
    
    func testValidateAllTilesNoMatches() async {
        let entity1 = await Entity()
        entity1.name = "red"
        let entity2 = await Entity()
        entity2.name = "yellow"
        let entity3 = await Entity()
        entity3.name = "blue"
        
        mockEntityManager.entities = [
            (entity: entity1, column: 0, row: 0),
            (entity: entity2, column: 1, row: 0),
            (entity: entity3, column: 2, row: 0)
        ]
        
        await boardManager.handleEntityPress(entity1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            XCTAssertFalse(self.mockEntityManager.removeMatchesCalled)
        }
    }
}
