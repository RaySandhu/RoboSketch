//
//  ActionBar.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//

import SwiftUI

struct ActionBar: View {
    @Binding var paths: [ColoredPath]
    @State private var undone: ColoredPath?

    var body: some View {
        HStack {
            Button("Save") {
                // TODO: Save action here
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .orange))
            
            Button("Redo") {
                if (undone != nil) {
                    paths.append(undone!)
                    undone = nil
                }
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .yellow))
            
            Button("Undo") {
                undone = paths.popLast()
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .blue))
            
            Button("Clear") {
                paths = []
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
