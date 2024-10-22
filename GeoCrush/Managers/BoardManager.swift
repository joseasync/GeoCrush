//
//  BoardManager.swift
//  GeoCrush
//
//  Created by Jose Cruz on 16/10/2024.
//

import Foundation
import RealityKit
import AVFoundation

class BoardManager {
    private let entityManager: EntityManager
    private let rowCount: Int
    private let columnCount: Int
    private var audioPlayer: AVAudioPlayer?
    
    enum soundBoard {
        case removed
        case tapped
        case moved
    }
    
    init(entityManager: EntityManager, rowCount: Int, columnCount: Int) {
        self.entityManager = entityManager
        self.rowCount = rowCount
        self.columnCount = columnCount
    }
    
    func handleEntityPress(_ entity: Entity) async {
        guard let (column, row) = await entityManager.findEntityInColumns(entity) else { return }
        playSound(sound: .tapped)
        await entityManager.removeMatches([(entity, column, row)])
        await entityManager.moveDownEntitiesInColumn(columnIndex: column)
        do {
            try await self.validateAllTiles()
        } catch {
            print("Error occurred while handling entity press: \(error)")
        }
    }
    
    private func validateAllTiles() async throws {
        var didRemoveMatches: Bool = false
        var matchingEntities: [(entity: Entity, column: Int, row: Int)] = []
        var currentAssetType: String? = nil
        var batchesToBeRemoved: [[(entity: Entity, column: Int, row: Int)]] = []
        
        for row in 0..<self.rowCount {
            for column in 0..<self.columnCount {
                if let entityInfo = self.entityManager.getEntityAt(column: column, row: row) {
                    if await entityInfo.entity.name == currentAssetType {
                        matchingEntities.append((entity: entityInfo.entity, column: column, row: row))
                    } else {
                        if matchingEntities.count >= 3 {
                            batchesToBeRemoved.append(matchingEntities)
                            didRemoveMatches = true
                        }
                        currentAssetType = await entityInfo.entity.name
                        matchingEntities = [(entity: entityInfo.entity, column: column, row: row)]
                    }
                } else {
                    if matchingEntities.count >= 3 {
                        batchesToBeRemoved.append(matchingEntities)
                        didRemoveMatches = true
                    }
                    currentAssetType = nil
                    matchingEntities.removeAll()
                }
            }
            
            if matchingEntities.count >= 3 {
                batchesToBeRemoved.append(matchingEntities)
                didRemoveMatches = true
            }
            
            currentAssetType = nil
            matchingEntities.removeAll()
        }
        
        for batch in batchesToBeRemoved {
            let matchingEntities = batch
            //Delay for compreensive effect :)
            try await Task.sleep(nanoseconds: 1_000_000_000)
            playSound(sound: .removed)
            await self.entityManager.removeMatches(matchingEntities)
        }
        
        //Check if the new tiles board has matches
        if didRemoveMatches {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            playSound(sound: .moved)
            for column in 0..<self.columnCount {
                await self.entityManager.moveDownEntitiesInColumn(columnIndex: column)
            }
            try await self.validateAllTiles()
        }
    }
    
    func playSound(sound: soundBoard) {
        var soundURL: URL?
        switch sound {
        case .tapped:
            soundURL = Bundle.main.url(forResource: "tapped", withExtension: "mp3")
        case .removed:
            soundURL = Bundle.main.url(forResource: "removed", withExtension: "mp3")
        case .moved:
            soundURL = Bundle.main.url(forResource: "moved", withExtension: "mp3")
        }
            
        if let validSoundUrl = soundURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: validSoundUrl)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error: Could not play sound file.")
            }
        } else {
            print("Error: Sound file not found.")
        }
    }
}
