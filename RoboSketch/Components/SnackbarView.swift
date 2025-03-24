//
//  SnackbarView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-24.
//
import SwiftUI

struct SnackbarView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
    }
}
