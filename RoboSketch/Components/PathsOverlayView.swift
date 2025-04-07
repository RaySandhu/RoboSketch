//
//  PathsOverlayView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-22.
//  Updated by Jarin Thundathil on 2025-04-04.



import SwiftUI

struct PathsOverlayView: View {
    @Binding var paths: [ColoredPath]
    
    var body: some View {

        GeometryReader { geometry in
            ZStack {
                ForEach(paths) { coloredPath in
                    // Draw the path
                    Path(coloredPath.path.cgPath)
                        .stroke(coloredPath.color, lineWidth: 2)

                    // Draw interactive nodes
                    ForEach(coloredPath.nodes) { node in
                        NodeView(node: node, position: node.position, color: coloredPath.color)
                    }
                }
            }
        }
    }
}



