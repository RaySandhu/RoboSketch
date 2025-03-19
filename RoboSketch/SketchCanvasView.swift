//
//  SketchCanvasView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//

import SwiftUI
import PencilKit

struct SketchCanvasView: UIViewRepresentable {
    var drawingColor: Color

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = RestrictedCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        
        // iOS 14+ tool picker – create your own instance
        let toolPicker = PKToolPicker() 
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        // Set the initial drawing tool using the provided drawingColor.
        canvasView.tool = PKInkingTool(.pen, color: UIColor(drawingColor), width: 5)
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update the allowed color and the current tool when the drawingColor changes.
         if let restricted = uiView as? RestrictedCanvasView {
             restricted.allowedColor = UIColor(drawingColor)
         }
        uiView.tool = PKInkingTool(.pen, color: UIColor(drawingColor), width: 5)
    }
}

