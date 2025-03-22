import SwiftUI
import PencilKit

// MARK: - ContentView

struct ContentView: View {
    @State private var drawingColor: Color = .red
    @State private var paths: [ColoredPath] = []  // Store finalized path objects
    // State for robot selection and drawing color
    @State private var selectedRobot: String? = "Robot 1"
    @State private var showBluetoothModal = false

    // Define a list of robots with their corresponding colors.
    let robots: [(name: String, color: Color)] = [
        ("Robot 1", .red),
        ("Robot 2", .blue),
        ("Robot 3", .green),
        ("Robot 4", .teal)
    ]
    var body: some View {
            VStack(spacing: 0) {
                // Top: Robot selector buttons
                HStack {
                    ForEach(robots, id: \.name) { robot in
                        RobotButton(
                            robotName: robot.name,
                            robotColor: robot.color,
                            selectedRobot: $selectedRobot,
                            drawingColor: $drawingColor,
                            onBluetooth: {
                                showBluetoothModal = true
                            }
                        )
                    }
                }
                .padding()

            ZStack {
                GridOverlayView()
                SketchCanvasView(drawingColor: drawingColor, paths: $paths)
                PathsOverlayView(paths: paths)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ActionBar()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
