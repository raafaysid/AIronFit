//
//  WorkoutSet.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/23/26.
//

import Foundation
import GRDB

struct WorkoutSet: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: UUID = UUID()
    var exerciseId: UUID
    var weight: Double
    var reps: Double
    var completedAt: Date = Date()
    
    static let databaseTableName = "workoutSet"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let exerciseId = Column(CodingKeys.exerciseId)
        static let weight = Column(CodingKeys.weight)
        static let reps = Column(CodingKeys.reps)
        static let completedAt = Column(CodingKeys.completedAt)
    }
}
