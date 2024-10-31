//
//  Score.swift
//  GeoCrush
//
//  Created by Jose Cruz on 30/10/2024.
//

class Score {
    var total: [AssetType: Int] = [:]
    
    init() {
        for type in AssetType.allCases {
            total[type] = 0
        }
    }
    
    func incrementScore(for type: AssetType) {
        total[type, default: 0] += 1
    }
    
    func getScore(for type: AssetType) -> Int {
        return total[type, default: 0]
    }
}
