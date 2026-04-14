//
//  WorkoutViewModel.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/30/26.
//
import Foundation
import SwiftUI

class WorkoutViewModel: ObservableObject {
    
    @Published var currentWorkout: Workout = Workout()
    @Published var currentExerciseIndex: Int = 0
    @Published var restSeconds: Int = 0
    @Published var isResting: Bool = false
    @Published var workoutStarted: Bool = false
    
    private var restTimer: Timer?
    
    var currentExercise: Exercise? {
        guard !currentWorkout.exercises.isEmpty else { return nil }
        return currentWorkout.exercises[currentExerciseIndex]
    }
    
    var currentSetNumber: Int {
        currentExercise?.sets.count ?? 0
    }
    
    //workout Control
    
    func startWorkout() {
        currentWorkout = Workout()
        currentExerciseIndex = 0
        workoutStarted = true
    }
    
    func addExercise(_ exercise: Exercise) {
        currentWorkout.exercises.append(exercise)
    }
    
    func logSet(weight: Double, reps: Double) {
        guard currentExercise != nil else { return }
        
        let exerciseId = currentWorkout.exercises[currentExerciseIndex].id
        let newSet = WorkoutSet(exerciseId: exerciseId, weight: weight, reps: reps)
        currentWorkout.exercises[currentExerciseIndex].sets.append(newSet)
        
        startRestTimer()
    }
    
    func nextExercise() {
        if currentExerciseIndex < currentWorkout.exercises.count - 1 {
            currentExerciseIndex += 1
            
        }
    }
    func previousExercise() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
        }
    }

    func jumpToExercise(index: Int) {
        guard index >= 0 && index < currentWorkout.exercises.count else { return }
        currentExerciseIndex = index
    }
    
    func endWorkout() {
        currentWorkout.duration = Date().timeIntervalSince(currentWorkout.date)
        stopRestTimer()
        
        do {
            try DatabaseService.shared.saveWorkout(currentWorkout)
            print("[success] Workout saved successfully")
        } catch {
            print("[error] Failed to save workout: \(error)")
        }
        
        workoutStarted = false
    }
    
    // rest Timer
    
    func startRestTimer() {
        stopRestTimer()
        restSeconds = 0
        isResting = true
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.restSeconds += 1
        }
    }
    
    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isResting = false
        restSeconds = 0
    }
    
    var restTimeFormatted: String {
        let minutes = restSeconds / 60
        let seconds = restSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
