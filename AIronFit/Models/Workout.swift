//
//  Workout.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/23/26.
//

import Foundation

struct Workout: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var exercises: [Exercise] = []
    var duration: TimeInterval = 0
    var notes: String = ""
    
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var totalVolume: Double {
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { $0 + ($1.weight * $1.reps) }
        }
    }
}
