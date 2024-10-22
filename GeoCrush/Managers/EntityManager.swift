//
//  EntityManager.swift
//  GeoCrush
//
//  Created by Jose Cruz on 16/10/2024.
//

import RealityKit
import Foundation

class EntityManager {
    private let root: Entity
    private let assetLoader: AssetLoader
    private let rowCount: Int
    private let columnCount: Int
    private let objectSpace: Float = 1.2
    private var entitiesInColumns: [Int: [(entity: Entity, row: Int)]] = [:]
    
    init(root: Entity, assetLoader: AssetLoader, rowCount: Int, columnCount: Int) {
        self.root = root
        self.assetLoader = assetLoader
        self.rowCount = rowCount
        self.columnCount = columnCount
        
        for column in 0..<columnCount {
            entitiesInColumns[column] = []
        }
    }
    
    @MainActor
    func populateBoard() async {
        let assets = await loadAssets()
        
        for i in 0..<rowCount {
            for j in 0..<columnCount {
                let randomAsset = assets.randomElement()!
                let position = calculatePosition(row: i, column: j)
                randomAsset.position = [position.x, position.y, 0]
                let clonedAsset = randomAsset.clone(recursive: false)
                root.addChild(clonedAsset)
                entitiesInColumns[j]?.append((entity: clonedAsset, row: i))
            }
        }
    }
    
    func findEntityInColumns(_ entity: Entity) async -> (Int, Int)? {
        var result: (Int, Int)?
        for (column, entities) in entitiesInColumns {
            if let foundEntity = entities.first(where: { $0.entity == entity }) {
                result = (column, foundEntity.row)
                break
            }
        }
        return result
        
    }
    
    func getEntityAt(column: Int, row: Int) -> (entity: Entity, row: Int)? {
        guard let columnEntities = entitiesInColumns[column] else { return nil }
        return columnEntities.first(where: { $0.row == row })
    }
    
    func moveDownEntitiesInColumn(columnIndex: Int) async{
        guard var columList = entitiesInColumns[columnIndex] else { return }
        columList.sort(by: { $0.row < $1.row })
        for index in 0..<columList.count {
            columList[index].row = index
            let newPosition = calculatePosition(row: index, column: columnIndex)
            await animateEntity(columList[index].entity, to: newPosition)
        }
        entitiesInColumns[columnIndex] = columList
    }
    
    func removeMatches(_ entities: [(entity: Entity, column: Int, row: Int)]) async {
        for entityInfo in entities {
            await entityInfo.entity.removeFromParent()
            let columList = entitiesInColumns[entityInfo.column]
            entitiesInColumns[entityInfo.column] = columList?.filter({ $0.row != entityInfo.row})
        }
    }
    
    func calculatePosition(row: Int, column: Int) -> SIMD3<Float> {
        let x = (Float(column) - Float(columnCount) / 2.0) * objectSpace
        let y = (Float(row) - Float(rowCount) / 2.0) * objectSpace
        return [x, y, 0]
    }
        
    @MainActor
    private func animateEntity(_ entity: Entity, to newPosition: SIMD3<Float>) async {
        let animationDuration: TimeInterval = 0.9
        entity.move(to: Transform(translation: newPosition), relativeTo: self.root, duration: animationDuration)
    }
    
    private func loadAssets() async -> [Entity] {
        let red = await assetLoader.load(.red)
        let yellow = await assetLoader.load(.yellow)
        let blue = await assetLoader.load(.blue)
        let green = await assetLoader.load(.green)
        return [red, yellow, blue, green]
    }
}
