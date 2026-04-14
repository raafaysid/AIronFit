//
//  ExercisePickerViewModel.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/30/26.
//

import Foundation

class ExercisePickerViewModel: ObservableObject {
    
    @Published var exercises: [ExerciseDBExercise] = []
    @Published var bodyParts: [String] = []
    @Published var selectedBodyPart: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    
    private let service = ExerciseService.shared
    private let bodyPartMapping: [String: String] = [
        "upper arms": "Arms",
        "lower arms": "Arms",
        "upper legs": "Legs",
        "lower legs": "Legs",
        "back": "Back",
        "chest": "Chest",
        "shoulders": "Shoulders",
        "neck": "Neck",
        "waist": "Core",
        "cardio": "Cardio"
    ]

    var displayBodyParts: [String] {
        let mapped = bodyParts.map { bodyPartMapping[$0.lowercased()] ?? $0.capitalized }
        return Array(Set(mapped)).sorted()
    }

    func apiBodyParts(for displayName: String) -> [String] {
        return bodyPartMapping
            .filter { $0.value == displayName }
            .map { $0.key }
    }
    
    var filteredExercises: [ExerciseDBExercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func loadBodyParts() async {
        await MainActor.run { isLoading = true }
        
        do {
            let parts = try await service.fetchBodyParts()
            let _ = try await service.fetchEquipmentList()
            await MainActor.run {
                self.bodyParts = parts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load body parts"
                self.isLoading = false
            }
        }
    }
    
    func loadExercises(for displayName: String) async {
        await MainActor.run {
            isLoading = true
            selectedBodyPart = displayName
            exercises = []
        }
        
        do {
            let apiParts = apiBodyParts(for: displayName)
            let partsToFetch = apiParts.isEmpty ? [displayName.lowercased()] : apiParts
            
            var fetchedResults: [ExerciseDBExercise] = []
            for part in partsToFetch {
                let results = try await service.fetchExercises(bodyPart: part)
                fetchedResults += results
            }
            
            let finalResults = fetchedResults
            await MainActor.run {
                self.exercises = finalResults
                print("[success] Exercises Set: \(self.exercises.count)")
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load exercises"
                self.isLoading = false
            }
        }
    }
}
