import PencilKit
import UIKit

class RestrictedCanvasView: PKCanvasView {
    /// The color that is allowed to be drawn. If a stroke with this color already exists,
    /// new inking touches are ignored.
    var allowedColor: UIColor = .red

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if the current tool is an inking tool (i.e. a drawing tool).
        if let inkingTool = self.tool as? PKInkingTool {
            // If a stroke of the allowed color is already present, ignore new drawing touches.
            let drawingHasStroke = self.drawing.strokes.contains { stroke in
                return stroke.ink.color.isEqual(allowedColor)
            }
            if drawingHasStroke {
                // Ignore touches to prevent drawing another stroke of the same color.
                return
            }
        }
        // Otherwise, process the touches normally.
        super.touchesBegan(touches, with: event)
    }
}
