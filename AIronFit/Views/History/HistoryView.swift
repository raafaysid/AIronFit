//
//  HistoryView.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/25/26.
//

import SwiftUI

struct HistoryView: View {
    @State private var workouts: [Workout] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //header
                HStack {
                    Text("Workout History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.orange)
                    Spacer()
                } else if workouts.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No workouts yet")
                            .foregroundColor(.gray)
                        Text("Complete a workout to see it here")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(workouts) { workout in
                                WorkoutHistoryCard(workout: workout)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
        .onAppear {
            loadWorkouts()
        }
    }
    
    func loadWorkouts() {
        do {
            workouts = try DatabaseService.shared.fetchAllWorkouts()
            isLoading = false
        } catch {
            print("[error] Failed to load workouts: \(error)")
            isLoading = false
        }
    }
}

// workout History Card

struct WorkoutHistoryCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.date, style: .date)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(workout.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(formatDuration(workout.duration))
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("\(workout.exercises.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Exercises")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text("\(workout.totalSets)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Sets")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(workout.totalVolume)) lbs")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Volume")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if !workout.exercises.isEmpty {
                Text(workout.exercises.map { $0.name }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        }
        return "\(minutes)m"
    }
}

#Preview {
    HistoryView()
}
