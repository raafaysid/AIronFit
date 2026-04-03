//
//  HomeView.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/23/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                //background color
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    
                    //logo and title
                    VStack(spacing: 8) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("AIronFit")
                            .font(.system(size: 42, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("Train smarter")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    //buttons
                    VStack(spacing: 16) {
                        //start Workout button
                        NavigationLink(destination: ActiveWorkoutView(viewModel: WorkoutViewModel())) {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text("Start Workout")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.black)
                            .cornerRadius(14)
                        }
                        
                        //AI recommendation button
                        NavigationLink(destination: Text("AI Recommendation - Coming Soon")) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                Text("What should I do today?")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom,32)
                    
                   
                }
                .padding(.top, 60)
            }
        }
    }
}

#Preview {
    HomeView()
}
