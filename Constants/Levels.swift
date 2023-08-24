//
//  Levels.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-13.
//

import Foundation

struct LevelTracker {
    var userPoints = 0

    var currentLevel: Int  {
        
        guard userPoints >= 0 else { return 0 }
                
        for (index, pointsThreshold) in LevelTracker.pointsThresholdPerLevel.enumerated() {
            if userPoints < pointsThreshold {
                return index
            }
        }
        return LevelTracker.pointsThresholdPerLevel.count
    }
    
     var currentLevelPointsThreshold: Int {
         guard currentLevel - 1 >= 0 else { return 0 }
         
        return LevelTracker.pointsThresholdPerLevel[currentLevel - 1]
    }
    
     var nextLevelPointsThreshold: Int {
         guard currentLevel >= 0 else { return 0 }
         
         return !isMaxLevel ? LevelTracker.pointsThresholdPerLevel[currentLevel] : 0
    }
    
     var pointsInLevel: Int {
         print("current thres \(currentLevelPointsThreshold)")
        return userPoints - currentLevelPointsThreshold
    }
    
     var requiredPointsToNextLevel: Int {
        return nextLevelPointsThreshold - currentLevelPointsThreshold
    }
    
    var isMaxLevel: Bool {
        return currentLevel >= LevelTracker.pointsThresholdPerLevel.count
    }
    
    static let pointsThresholdPerLevel = [0, 5, 10, 15, 25, 50, 75, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 650, 700, 750, 800, 850, 900, 950, 1000, 1100, 1200, 1300, 1400, 1500, 1750, 2000, 2500, 3000, 3500, 4500, 5000, 6000, 7500, 10000, 12500, 15000, 20000, 30000, 50000, 75000, 100000]
}

