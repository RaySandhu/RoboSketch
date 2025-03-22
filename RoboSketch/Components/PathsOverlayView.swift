//
//  PathsOverlayView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-22.
//

import SwiftUI
// MARK: - Overlay to Render Finalized Paths

struct PathsOverlayView: View {
    var paths: [ColoredPath]
    func printPaths() {
        print(paths)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(paths) { coloredPath in
                    // Create a SwiftUI Path from the UIBezierPath's CGPath.
                    Path(coloredPath.path.cgPath)
                        .stroke(coloredPath.color, lineWidth: 2)
                }
            }
        }
    }
}
