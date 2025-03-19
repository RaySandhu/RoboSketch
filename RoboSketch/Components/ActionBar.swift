//
//  ActionBar.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//

import SwiftUI

struct ActionBar: View {
    var body: some View {
        HStack {
            Button("Save") {
                // TODO: Save action here
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .orange))
            
            Button("Redo") {
                // TODO: Redo action here
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .yellow))
            
            Button("Undo") {
                // TODO: Undo action here
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .blue))
            
            Button("Delete") {
                // TODO: Delete action here
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .red))
            
            Button("Play") {
                // TODO: Play action here
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .green))
        }
        .background(Color(UIColor.systemGray6))
    }
}
