//
//  ExercisePickerView.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/30/26.
//

import SwiftUI

struct ExercisePickerView: View {
    @StateObject private var viewModel = ExercisePickerViewModel()
    @Environment(\.dismiss) private var dismiss
    var onExerciseSelected: (Exercise) -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //Header
                HStack {
                    Text("Add Exercise")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search exercises...", text: $viewModel.searchText)
                        .foregroundColor(.white)
                }
                .padding(12)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Body Part Filter
                if viewModel.selectedBodyPart == nil {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Muscle Group")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.orange)
                                Spacer()
                            }
                            .padding(.top, 40)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(viewModel.displayBodyParts, id: \.self) { part in
                                        Button {
                                            Task {
                                                await viewModel.loadExercises(for: part)
                                            }
                                        } label: {
                                            Text(part)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 16)
                                                .background(Color.white.opacity(0.08))
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }
                } else {
                    
                    // Back to muscle groups
                    Button {
                        viewModel.selectedBodyPart = nil
                        viewModel.exercises = []
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text(viewModel.selectedBodyPart?.capitalized ?? "")
                            Spacer()
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                    }
                    
                    // Exercise List
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .tint(.orange)
                        Spacer()
                    } else if viewModel.filteredExercises.isEmpty {
                        Spacer()
                        Text("No exercises found")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredExercises) { exercise in
                                    Button {
                                        onExerciseSelected(exercise.toExercise())
                                        dismiss()
                                    } label: {
                                        HStack(spacing: 16) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(exercise.name.capitalized)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.leading)
                                                HStack(spacing: 8) {
                                                    Text(exercise.target.capitalized)
                                                        .font(.caption)
                                                        .foregroundColor(.orange)
                                                    Text("·")
                                                        .foregroundColor(.gray)
                                                    Text(exercise.equipment.capitalized)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 24))
                                        }
                                        .padding(16)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .task {
            await viewModel.loadBodyParts()
        }
    }
}
