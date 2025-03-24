//
//  SketchCanvasView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//

import SwiftUI
import PencilKit
import CoreGraphics

extension CGPath {
    func forEach(_ body: @escaping (CGPathElement) -> Void) {
        let wrapper = BodyWrapper(body: body)
        let pointer = Unmanaged.passRetained(wrapper).toOpaque()
        self.apply(info: pointer) { (info, element) in
            let wrapper = Unmanaged<BodyWrapper>.fromOpaque(info!).takeUnretainedValue()
            wrapper.body(element.pointee)
        }
        Unmanaged<BodyWrapper>.fromOpaque(pointer).release()
    }
}

private class BodyWrapper {
    let body: (CGPathElement) -> Void
    init(body: @escaping (CGPathElement) -> Void) {
        self.body = body
    }
}


extension UIBezierPath {
    func toJSON() -> String? {
        var commands: [[String: Any]] = []
        
        self.cgPath.forEach { element in
            switch element.type {
            case .moveToPoint:
                let point = element.points[0]
                // Always add a new moveTo command.
                commands.append(["cmd": "moveTo", "points": [["x": point.x, "y": point.y]]])
                
            case .addLineToPoint:
                let point = element.points[0]
                // If the last command is a lineTo, append the point. Otherwise, create a new one.
                if let last = commands.last, let lastCmd = last["cmd"] as? String, lastCmd == "lineTo" {
                    var lastPoints = last["points"] as? [[String: CGFloat]] ?? []
                    lastPoints.append(["x": point.x, "y": point.y])
                    commands[commands.count - 1]["points"] = lastPoints
                } else {
                    commands.append(["cmd": "lineTo", "points": [["x": point.x, "y": point.y]]])
                }
                
            case .addQuadCurveToPoint:
                let controlPoint = element.points[0]
                let endPoint = element.points[1]
                commands.append([
                    "cmd": "quadCurveTo",
                    "points": [
                        ["controlX": controlPoint.x, "controlY": controlPoint.y],
                        ["x": endPoint.x, "y": endPoint.y]
                    ]
                ])
                
            case .addCurveToPoint:
                let controlPoint1 = element.points[0]
                let controlPoint2 = element.points[1]
                let endPoint = element.points[2]
                commands.append([
                    "cmd": "curveTo",
                    "points": [
                        ["control1X": controlPoint1.x, "control1Y": controlPoint1.y],
                        ["control2X": controlPoint2.x, "control2Y": controlPoint2.y],
                        ["x": endPoint.x, "y": endPoint.y]
                    ]
                ])
                
            case .closeSubpath:
                commands.append(["cmd": "closePath"])
                
            @unknown default:
                break
            }
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: commands, options: [.prettyPrinted]),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}

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
            let points = stroke.path.interpolatedPoints(by: PKStrokePath.InterpolatedSlice.Stride.distance(5.0))
            let pointArray = Array(points)
            guard let firstPoint = pointArray.first else { return }
            newPath.move(to: firstPoint.location)
            for point in pointArray.dropFirst() {
                newPath.addLine(to: point.location)
            }
            
            // Use the captured color so that this stroke keeps the original color.
            let coloredPath = ColoredPath(path: newPath, encodedPath: newPath.toJSON()!, color: strokeColor)
            self.parent.paths.append(coloredPath)
            canvasView.drawing = PKDrawing()
            
            print("Final stroke converted to path")
            // JARIN: This is where the points on the line are displayed
                // will likely use some cleaned up version of these for path encoding
            print(coloredPath.encodedPath)
        }



    }

}
