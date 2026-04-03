//
//  ProgressView.swift
//  AIronFit
//
//  Created by Raafay Siddiqui on 3/25/26.
//

import SwiftUI

struct ProgressView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Progress")
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ProgressView()
}
