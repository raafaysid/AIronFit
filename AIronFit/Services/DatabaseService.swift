//
//  DatabaseService.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 4/7/26.
//

import Foundation
import GRDB

class DatabaseService {
    
    static let shared = DatabaseService()
    private var dbQueue: DatabaseQueue!
    
    private init() {
        do {
            let databaseURL = try FileManager.default
                .url(for: .applicationSupportDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("AIronFit.sqlite")
            
            dbQueue = try DatabaseQueue(path: databaseURL.path)
            try setupDatabase()
            print("[success] Database initialized at: \(databaseURL.path)")
        } catch {
            print("[fail] Database initialization failed: \(error)")
        }
    }
    
    // setup Tables
    
    private func setupDatabase() throws {
        try dbQueue.write { db in
            
            try db.create(table: "workout", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("date", .datetime).notNull()
                t.column("duration", .double).notNull().defaults(to: 0)
                t.column("notes", .text).notNull().defaults(to: "")
            }
            
            try db.create(table: "exercise", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("workoutId", .text).notNull()
                t.column("name", .text).notNull()
                t.column("muscleGroup", .text).notNull()
                t.column("targetMuscle", .text).notNull()
                t.column("equipmentType", .text).notNull()
                t.column("notes", .text).notNull().defaults(to: "")
            }
            
            try db.create(table: "workoutSet", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("exerciseId", .text).notNull()
                t.column("weight", .double).notNull()
                t.column("reps", .double).notNull()
                t.column("completedAt", .datetime).notNull()
            }
        }
    }
    // save Workout
    
    func saveWorkout(_ workout: Workout) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: """
                    INSERT OR REPLACE INTO workout (id, date, duration, notes)
                    VALUES (?, ?, ?, ?)
                """,
                arguments: [
                    workout.id.uuidString,
                    workout.date,
                    workout.duration,
                    workout.notes
                ]
            )
            
            for exercise in workout.exercises {
                try db.execute(
                    sql: """
                        INSERT OR REPLACE INTO exercise 
                        (id, workoutId, name, muscleGroup, targetMuscle, equipmentType, notes)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    arguments: [
                        exercise.id.uuidString,
                        workout.id.uuidString,
                        exercise.name,
                        exercise.muscleGroup,
                        exercise.targetMuscle,
                        exercise.equipmentType,
                        exercise.notes
                    ]
                )
                
                for set in exercise.sets {
                    try db.execute(
                        sql: """
                            INSERT OR REPLACE INTO workoutSet
                            (id, exerciseId, weight, reps, completedAt)
                            VALUES (?, ?, ?, ?, ?)
                        """,
                        arguments: [
                            set.id.uuidString,
                            exercise.id.uuidString,
                            set.weight,
                            set.reps,
                            set.completedAt
                        ]
                    )
                }
            }
        }
    }
    
    // fetch All Workouts
    
    func fetchAllWorkouts() throws -> [Workout] {
        try dbQueue.read { db in
            var workouts = try Workout
                .order(Workout.Columns.date.desc)
                .fetchAll(db)
            
            for i in workouts.indices {
                let workoutId = workouts[i].id.uuidString
                var exercises = try Exercise
                    .filter(sql: "workoutId = ?", arguments: [workoutId])
                    .fetchAll(db)
                
                for j in exercises.indices {
                    let exerciseId = exercises[j].id.uuidString
                    exercises[j].sets = try WorkoutSet
                        .filter(sql: "exerciseId = ?", arguments: [exerciseId])
                        .fetchAll(db)
                }
                
                workouts[i].exercises = exercises
            }
            
            return workouts
        }
    }
    
    //fetch Recent Workouts for AI
    
    func fetchRecentWorkouts(days: Int = 7) throws -> [Workout] {
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: Date()
        ) ?? Date()
        
        return try dbQueue.read { db in
            var workouts = try Workout
                .filter(Workout.Columns.date >= cutoffDate)
                .order(Workout.Columns.date.desc)
                .fetchAll(db)
            
            for i in workouts.indices {
                let workoutId = workouts[i].id.uuidString
                var exercises = try Exercise
                    .filter(sql: "workoutId = ?", arguments: [workoutId])
                    .fetchAll(db)

                for j in exercises.indices {
                    let exerciseId = exercises[j].id.uuidString
                    exercises[j].sets = try WorkoutSet
                        .filter(sql: "exerciseId = ?", arguments: [exerciseId])
                        .fetchAll(db)
                }
                
                workouts[i].exercises = exercises
            }
            
            return workouts
        }
    }
    
    // delete Workout
    
    func deleteWorkout(_ workout: Workout) throws {
        try dbQueue.write { db in
            try workout.delete(db)
        }
    }
}
