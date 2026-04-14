//
//  Exercise.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/23/26.
//

import Foundation
import GRDB

struct Exercise: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: UUID = UUID()
    var workoutId: UUID
    var name: String
    var muscleGroup: String
    var targetMuscle: String
    var equipmentType: String
    var notes: String = ""
    
    static let databaseTableName = "exercise"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let workoutId = Column(CodingKeys.workoutId)
        static let name = Column(CodingKeys.name)
        static let muscleGroup = Column(CodingKeys.muscleGroup)
        static let targetMuscle = Column(CodingKeys.targetMuscle)
        static let equipmentType = Column(CodingKeys.equipmentType)
        static let notes = Column(CodingKeys.notes)
    }
    
    //relationship to sets, not stored in DB, loaded separately
    var sets: [WorkoutSet] = []
    
    enum CodingKeys: String, CodingKey {
        case id, workoutId, name, muscleGroup, targetMuscle, equipmentType, notes
    }
}
