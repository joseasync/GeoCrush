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
    private let score: Score
    private var scoreAssetEntities: [AssetType: Entity] = [:]
    private var scoreTextEntities: [AssetType: Entity] = [:]
    
    init(root: Entity, assetLoader: AssetLoader, rowCount: Int, columnCount: Int) {
        self.root = root
        self.assetLoader = assetLoader
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.score = Score()
        
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
    
    @MainActor
    func setupScoreboard() async {
        let assets = await loadAssets()
       
        // Setup score displays below the board
        for (index, scoreTotal) in self.score.total.enumerated() {
            let displayPosition = calculateScorePosition(for: index)
            let scoreDisplay = assets.first(where: { $0.name == scoreTotal.key.rawValue })?.clone(recursive: false)
            scoreDisplay?.position = [displayPosition.x, displayPosition.y, 0]
            root.addChild(scoreDisplay!)
            scoreAssetEntities[scoreTotal.key] = scoreDisplay
            
            let scoreText = createScoreTextEntity(for: scoreTotal.key)
            scoreText.position = [displayPosition.x - 0.3, displayPosition.y + 0.5, 0]
            root.addChild(scoreText)
            scoreTextEntities[scoreTotal.key] = scoreText
            
            updateScoreDisplay(for: scoreTotal.key)
        }
    }
    
    @MainActor
    private func updateScoreDisplay(for type: AssetType) {
        if let scoreTextEntity = scoreTextEntities[type] as? ModelEntity {
            let newScore = score.total[type, default: 0]
               let textMesh = MeshResource.generateText("\(newScore)", extrusionDepth: 0.1, font: .systemFont(ofSize: 1), containerFrame: .zero, alignment: .center, lineBreakMode: .byTruncatingTail)
               scoreTextEntity.model = ModelComponent(mesh: textMesh, materials: [SimpleMaterial(color: .white, isMetallic: false)])
           }
    }
    
    //TODO - Future I'll move the score to a separated class
    private func createScoreTextEntity(for type: AssetType) -> Entity {
        let textMesh = MeshResource.generateText("0", extrusionDepth: 0.1, font: .systemFont(ofSize: 1), containerFrame: .zero, alignment: .center, lineBreakMode: .byTruncatingTail)
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        return textEntity
    }
    
    
    func updateScore(for type: String, amount: Int) async {
        
        guard let assetType = AssetType.allCases.first(where: {$0.rawValue == type}) else { return }
        score.total[assetType, default: 0] += amount
        await updateScoreDisplay(for: assetType)
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
        
    @MainActor
    private func animateEntity(_ entity: Entity, to newPosition: SIMD3<Float>) async {
        let animationDuration: TimeInterval = 0.9
        entity.move(to: Transform(translation: newPosition), relativeTo: self.root, duration: animationDuration)
    }
    
    private func calculatePosition(row: Int, column: Int) -> SIMD3<Float> {
        let x = (Float(column) - Float(columnCount) / 2.0) * objectSpace
        let y = (Float(row) - Float(rowCount) / 2.0) * objectSpace
        return [x, y, 0]
    }
    
    private func calculateScorePosition(for index: Int) -> SIMD3<Float> {
        let x = (Float(index) - Float(score.total.count) / 2.0) * (objectSpace + 1)
        let y = -Float(rowCount / 2) * objectSpace - 3.0
        return [x, y, 0]
    }
    
    private func loadAssets() async -> [Entity] {
        let red = await assetLoader.load(.red)
        let yellow = await assetLoader.load(.yellow)
        let blue = await assetLoader.load(.blue)
        let green = await assetLoader.load(.green)
        return [red, yellow, blue, green]
    }
}
