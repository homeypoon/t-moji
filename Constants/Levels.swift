//
//  Levels.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-13.
//

import Foundation

struct Levels {
    static let maxPointsPerLevel: [Int: Int] = [
        1: 5, 2: 15, 3: 25, 4: 50, 5: 100, 6: 150, 7: 250,
        8: 500, 9: 750, 10: 850, 11: 1000, 12: 1200, 13: 1400, 14: 1600, 15: 1800, 16: 2000, 17: 2300, 18: 2600, 19: 2900, 20: 3200, 21: 3500, 22: 3800, 23: 4100, 24: 4400, 25: 4700, 26: 5000, 27: 5400, 28: 5800, 29: 6200, 30: 6600, 31: 7000, 32: 7400, 33: 7800, 34: 8200, 35: 8600, 36: 9000, 37: 9400, 38: 9800, 39: 10200, 40: 10600, 41: 11000, 42: 11400, 43: 11800, 44: 12200, 45: 12600, 46: 13000, 47: 13500, 48: 14000, 49: 14500, 50: 15000, 51: 15500, 52: 16000, 53: 16500, 54: 17000, 55: 17500, 56: 18000, 57: 18500, 58: 19000, 59: 19500, 60: 20000
    ]
    
    static func getCorrespondingLevelAndMaxPoints(for currentPoints: Int) -> (level: Int, minPoints: Float, maxPoints: Float) {
        var correspondingLevel = 1
        
        while correspondingLevel < maxPointsPerLevel.count - 1 && currentPoints >= maxPointsPerLevel[correspondingLevel]! {
            
            if currentPoints == maxPointsPerLevel[correspondingLevel]! {
                let minPointsForCorrespondingLevel: Int = correspondingLevel >= 2 ? maxPointsPerLevel[correspondingLevel - 1]! : 0
                let maxPointsForCorrespondingLevel = maxPointsPerLevel[correspondingLevel]!
                return (level: correspondingLevel, minPoints: Float(minPointsForCorrespondingLevel), maxPoints: Float(maxPointsForCorrespondingLevel))
            } else if currentPoints > maxPointsPerLevel[correspondingLevel]! {
                correspondingLevel += 1
            }
        }
        
        let minPointsForCorrespondingLevel: Int = correspondingLevel >= 2 ? maxPointsPerLevel[correspondingLevel - 1]! : 0
        
        let maxPointsForCorrespondingLevel = maxPointsPerLevel[correspondingLevel]!
        return (level: correspondingLevel, minPoints: Float(minPointsForCorrespondingLevel), maxPoints: Float(maxPointsForCorrespondingLevel))
    }
    
}

