//
//  WorkoutCompleteView.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 4/14/26.
//

import SwiftUI

struct WorkoutCompleteView: View {
    let workout: Workout
    var onDismiss: () -> Void
    
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // trophy and Title
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Circle()
                            .fill(Color.orange.opacity(0.08))
                            .frame(width: 130, height: 130)
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                    }
                    .scaleEffect(animateContent ? 1.0 : 0.5)
                    .opacity(animateContent ? 1.0 : 0)
                    
                    Text("Workout Complete!")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                        .opacity(animateContent ? 1.0 : 0)
                    
                    Text("Saved to your history")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .opacity(animateContent ? 1.0 : 0)
                }
                
                Spacer()
                
                // stats Row
                HStack(spacing: 0) {
                    statView(value: formatDuration(workout.duration), label: "Duration")
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .frame(height: 40)
                    statView(value: "\(workout.exercises.count)", label: "Exercises")
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .frame(height: 40)
                    statView(value: "\(workout.totalSets)", label: "Sets")
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .frame(height: 40)
                    statView(value: "\(Int(workout.totalVolume)) lbs", label: "Volume")
                }
                .padding(.vertical, 24)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 20)
                
                // exercise List
                VStack(spacing: 8) {
                    ForEach(workout.exercises) { exercise in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Text(exercise.muscleGroup)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("\(exercise.sets.count) sets")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 30)
                
                Spacer()
                
                // done Button
                Button {
                    onDismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .opacity(animateContent ? 1.0 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateContent = true
            }
        }
    }
    
    private func statView(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
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
    WorkoutCompleteView(workout: Workout(), onDismiss: {})
}
