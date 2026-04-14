//
//  Workout.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/23/26.
//

import Foundation
import GRDB

struct Workout: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var duration: TimeInterval = 0
    var notes: String = ""
    
    static let databaseTableName = "workout"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let date = Column(CodingKeys.date)
        static let duration = Column(CodingKeys.duration)
        static let notes = Column(CodingKeys.notes)
    }
    
    //not stored in DB. loaded via relationship
    var exercises: [Exercise] = []
    
    enum CodingKeys: String, CodingKey {
        case id, date, duration, notes
    }
    
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var totalVolume: Double {
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { $0 + ($1.weight * $1.reps) }
        }
    }
}
