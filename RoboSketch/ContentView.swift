import SwiftUI

struct ContentView: View {
    // State for robot selection and drawing color
    @State private var selectedRobot: String? = "Robot 1"
    @State private var drawingColor: Color = .red
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

            // Center: Drawing surface (canvas) with optional grid overlay
            ZStack {
                GridOverlayView()
                SketchCanvasView(drawingColor: drawingColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
             
            // Bottom: Action toolbar
            ActionBar()
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showBluetoothModal) {
            BluetoothModalView()
        }
    }
}




#Preview {
    ContentView()
}
