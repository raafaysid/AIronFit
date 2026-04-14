//
//  ExerciseDBModel.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/30/26.
//

import Foundation

struct ExerciseDBExercise: Codable, Identifiable {
    let id: String
    let name: String
    let bodyPart: String
    let equipment: String
    let target: String
    let secondaryMuscles: [String]
    let instructions: [String]
    let gifUrl: String?
    
    func toExercise(workoutId: UUID = UUID()) -> Exercise {
        Exercise(
            workoutId: workoutId,
            name: name.capitalized,
            muscleGroup: bodyPart.capitalized,
            targetMuscle: target.capitalized,
            equipmentType: equipment.capitalized
        )
    }
}
