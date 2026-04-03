//
//  ExerciseService.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/30/26.
//

import Foundation

class ExerciseService {
    
    static let shared = ExerciseService()
    private init() {}
    
    private var allExercises: [ExerciseDBExercise] = []
    
    // load local JSON
    
    func loadExercises() {
        guard allExercises.isEmpty else { return }
        
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("[error] Could not find exercises.json in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            allExercises = try JSONDecoder().decode([ExerciseDBExercise].self, from: data)
            print("[success] Loaded \(allExercises.count) exercises from local database")
        } catch {
            print("[error] Failed to decode exercises.json: \(error)")
        }
    }
    
    // fetch exercises
    
    func fetchExercises(bodyPart: String? = nil, equipment: String? = nil) async throws -> [ExerciseDBExercise] {
        loadExercises()
        
        var results = allExercises
        
        if let bodyPart = bodyPart {
            results = results.filter {
                $0.bodyPart.lowercased() == bodyPart.lowercased()
            }
        }
        
        if let equipment = equipment {
            results = results.filter {
                $0.equipment.lowercased() == equipment.lowercased()
            }
        }
        
        return results
    }
    
    //fetch body parts
    
    func fetchBodyParts() async throws -> [String] {
        loadExercises()
        let parts = Array(Set(allExercises.map { $0.bodyPart.lowercased() })).sorted()
        return parts
    }
    
    // fetch equipment list
    
    func fetchEquipmentList() async throws -> [String] {
        loadExercises()
        let equipment = Array(Set(allExercises.map { $0.equipment.lowercased() })).sorted()
        return equipment
    }
}
