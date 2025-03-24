//
//  ColoredPath.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-22.
//

import SwiftUI

struct ColoredPath: Identifiable {
    // likely will need to include the robotName optionally
    let id = UUID()
    let path: UIBezierPath
    let color: Color
}
