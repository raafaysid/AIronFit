//
//  WorkoutSet.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/23/26.
//

import Foundation

struct WorkoutSet: Identifiable, Codable {
    var id: UUID = UUID()
    var weight: Double
    var reps: Double
    var completedAt: Date = Date()
}
