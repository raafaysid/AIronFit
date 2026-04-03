//
//  Exercise.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/23/26.
//

import Foundation

struct Exercise: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var muscleGroup: String
    var targetMuscle: String
    var equipmentType: String
    var sets: [WorkoutSet] = []
    var notes: String = ""
}
