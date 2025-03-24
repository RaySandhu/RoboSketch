//
//  SketchCanvasView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//

import SwiftUI
import PencilKit

struct SketchCanvasView: UIViewRepresentable {
    @Binding var drawingColor: Color
    @Binding var paths: [ColoredPath]

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = CustomCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput // change to pencilOnly

        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        canvasView.tool = PKInkingTool(.pen, color: UIColor(drawingColor), width: 5)
        canvasView.delegate = context.coordinator
        
        // Capture the coordinator so we always refer to the updated parent values.
        let coordinator = context.coordinator
        (canvasView as? CustomCanvasView)?.onStrokeEnd = { stroke in
            guard let stroke = stroke else { return }
            
            // Use coordinator.parent to get the current drawingColor.
            if coordinator.parent.paths.contains(where: { $0.color == coordinator.parent.drawingColor }) {
                NotificationCenter.default.post(name: .snackbarMessage,
                                                object: "Additional paths of the same color are not allowed")
                canvasView.drawing = PKDrawing()
                return
            }
            
            coordinator.convertStrokeToPath(stroke, in: canvasView)
        }
        
        return canvasView
    }


    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = PKInkingTool(.pen, color: UIColor(drawingColor), width: 5)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator to observe drawing changes.
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: SketchCanvasView

        init(_ parent: SketchCanvasView) {
            self.parent = parent
        }
        
        func convertStrokeToPath(_ stroke: PKStroke, in canvasView: PKCanvasView) {
            // Capture the current drawing color before any delay or further processing.
            let strokeColor = self.parent.drawingColor

            let newPath = UIBezierPath()
            let points = stroke.path.interpolatedPoints(by: PKStrokePath.InterpolatedSlice.Stride.distance(1.0))
            let pointArray = Array(points)
            guard let firstPoint = pointArray.first else { return }
            newPath.move(to: firstPoint.location)
            for point in pointArray.dropFirst() {
                newPath.addLine(to: point.location)
            }
            
            // Use the captured color so that this stroke keeps the original color.
            let coloredPath = ColoredPath(path: newPath, color: strokeColor)
            self.parent.paths.append(coloredPath)
            canvasView.drawing = PKDrawing()
            
            print("Final stroke converted to path")
            // JARIN: This is where the points on the line are displayed
                // will likely use some cleaned up version of these for path encoding
            print(newPath) 
        }



    }

}
