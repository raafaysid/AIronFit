//
//  ActiveWorkoutView.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/30/26.
//

import SwiftUI

struct ActiveWorkoutView: View {
    @StateObject var viewModel: WorkoutViewModel
    @State private var weightInput: String = ""
    @State private var repsInput: String = ""
    @State private var showExercisePicker = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //  Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active Workout")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(Date(), style: .time)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button("End Workout") {
                        viewModel.endWorkout()
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                //  Rest Timer
                if viewModel.isResting {
                    VStack(spacing: 4) {
                        Text("Rest Time")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(viewModel.restTimeFormatted)
                            .font(.system(size: 48, weight: .black, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                
                // Current Exercise
                if let exercise = viewModel.currentExercise {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.muscleGroup.uppercased())
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .fontWeight(.semibold)
                                Text(exercise.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(exercise.targetMuscle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("Set \(viewModel.currentSetNumber + 1)")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(10)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    
                    //  Previous Sets
                    if !exercise.sets.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Previous Sets")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 24)
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(exercise.sets) { set in
                                        HStack {
                                            Text("Set \(exercise.sets.firstIndex(where: { $0.id == set.id })! + 1)")
                                                .foregroundColor(.gray)
                                                .font(.subheadline)
                                            Spacer()
                                            Text("\(set.weight, specifier: "%.1f") lbs")
                                                .foregroundColor(.white)
                                                .font(.subheadline)
                                            Text("×")
                                                .foregroundColor(.gray)
                                            Text("\(set.reps, specifier: "%.1f") reps")
                                                .foregroundColor(.white)
                                                .font(.subheadline)
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                }
                            }
                            .frame(maxHeight: 120)
                        }
                        .padding(.bottom, 24)
                    }
                    
                } else {
                    // no exercise selected yet
                    VStack(spacing: 12) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Add your first exercise")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Tap the button below to get started")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                
                Spacer()
                
                // Log Set Input
                if viewModel.currentExercise != nil {
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            VStack(spacing: 6) {
                                Text("Weight (lbs)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("0", text: $weightInput)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)
                            }
                            
                            VStack(spacing: 6) {
                                Text("Reps")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("0", text: $repsInput)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button {
                            if let weight = Double(weightInput),
                               let reps = Double(repsInput) {
                                viewModel.logSet(weight: weight, reps: reps)
                                weightInput = ""
                                repsInput = ""
                            }
                        } label: {
                            Text("Log Set")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.black)
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                
                //  Bottom Buttons
                HStack(spacing: 12) {
                    Button {
                        showExercisePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Exercise")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    if viewModel.currentWorkout.exercises.count > 1 {
                        Button {
                            viewModel.nextExercise()
                        } label: {
                            HStack {
                                Text("Next Exercise")
                                Image(systemName: "arrow.right")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                                                        .frame(maxWidth: .infinity)
                                                        .padding()
                                                        .background(Color.orange.opacity(0.15))
                                                        .foregroundColor(.orange)
                                                        .cornerRadius(12)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 24)
                                            .padding(.bottom, 32)
                                        }
                                    }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView { selectedExercise in
                viewModel.addExercise(selectedExercise)
                showExercisePicker = false
            }
        }
                                }
                            }

                            #Preview {
                                ActiveWorkoutView(viewModel: WorkoutViewModel())
                            }
