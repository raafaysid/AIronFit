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
    @State private var showExerciseJumpList = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if viewModel.isResting {
                    restTimerView
                }
                
                if let exercise = viewModel.currentExercise {
                    currentExerciseView(exercise: exercise)
                    setsTableView(exercise: exercise)
                } else {
                    emptyStateView
                }
                
                Spacer()
                
                if viewModel.currentExercise != nil {
                    logSetView
                }
                
                navigationButtonsView
                addExerciseButton
            }
        }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView { selectedExercise in
                viewModel.addExercise(selectedExercise)
                showExercisePicker = false
            }
        }
        .sheet(isPresented: $showExerciseJumpList) {
            exerciseJumpListSheet
        }
    }
    
    // header
    private var headerView: some View {
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
        .padding(.bottom, 16)
    }
    
    // rest Timer
    private var restTimerView: some View {
        VStack(spacing: 4) {
            Text("Rest Time")
                .font(.caption)
                .foregroundColor(.gray)
            Text(viewModel.restTimeFormatted)
                .font(.system(size: 48, weight: .black, design: .monospaced))
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }
    
    // current Exercise
    private func currentExerciseView(exercise: Exercise) -> some View {
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
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }
    
    // sets Table
    private func setsTableView(exercise: Exercise) -> some View {
        ScrollView {
            if !exercise.sets.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("SET")
                            .frame(width: 40, alignment: .leading)
                        Spacer()
                        Text("WEIGHT")
                            .frame(width: 90, alignment: .trailing)
                        Text("REPS")
                            .frame(width: 70, alignment: .trailing)
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.horizontal, 24)
                    
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            Text("\(index + 1)")
                                .frame(width: 40, alignment: .leading)
                                .foregroundColor(.orange)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(set.weight, specifier: "%.1f") lbs")
                                .frame(width: 90, alignment: .trailing)
                                .foregroundColor(.white)
                            Text("\(set.reps, specifier: "%.0f") reps")
                                .frame(width: 70, alignment: .trailing)
                                .foregroundColor(.white)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        
                        if index < exercise.sets.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.05))
                                .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
        }
        .frame(minHeight: 120)
    }
    
    // empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Add your first exercise")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Tap the button below to get started")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // log Set
    private var logSetView: some View {
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
    
    // navigation Buttons
    private var navigationButtonsView: some View {
        Group {
            if viewModel.currentWorkout.exercises.count > 1 {
                HStack(spacing: 12) {
                    if viewModel.currentExerciseIndex > 0 {
                        let prevExercise = viewModel.currentWorkout.exercises[viewModel.currentExerciseIndex - 1]
                        Button {
                            viewModel.previousExercise()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.white)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Previous")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(prevExercise.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                        }
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                showExerciseJumpList = true
                            }
                        )
                    }
                    
                    if viewModel.currentExerciseIndex < viewModel.currentWorkout.exercises.count - 1 {
                        let nextExercise = viewModel.currentWorkout.exercises[viewModel.currentExerciseIndex + 1]
                        Button {
                            viewModel.nextExercise()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Next Up")
                                        .font(.caption)
                                        .foregroundColor(.orange.opacity(0.7))
                                    Text(nextExercise.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.orange)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(12)
                        }
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                showExerciseJumpList = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
        }
    }
    
    //add Exercise Button
    private var addExerciseButton: some View {
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
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
    
    // jump List Sheet
    private var exerciseJumpListSheet: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Jump to Exercise")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        showExerciseJumpList = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(viewModel.currentWorkout.exercises.enumerated()), id: \.element.id) { index, exercise in
                            Button {
                                viewModel.jumpToExercise(index: index)
                                showExerciseJumpList = false
                            } label: {
                                HStack(spacing: 16) {
                                    Text("\(index + 1)")
                                        .font(.headline)
                                        .foregroundColor(index == viewModel.currentExerciseIndex ? .black : .orange)
                                        .frame(width: 32, height: 32)
                                        .background(index == viewModel.currentExerciseIndex ? Color.orange : Color.orange.opacity(0.15))
                                        .cornerRadius(8)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Text("\(exercise.sets.count) sets logged")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if index == viewModel.currentExerciseIndex {
                                        Text("Current")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.orange.opacity(0.15))
                                            .cornerRadius(6)
                                    }
                                }
                                .padding(16)
                                .background(index == viewModel.currentExerciseIndex ? Color.orange.opacity(0.08) : Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

#Preview {
    ActiveWorkoutView(viewModel: WorkoutViewModel())
}
