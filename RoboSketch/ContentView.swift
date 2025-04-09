import SwiftUI
import PencilKit

// MARK: - ContentView
extension Notification.Name {
    static let snackbarMessage = Notification.Name("snackbarMessage")
}

struct ContentView: View {
    @State private var drawingColor: Color = .red
    @State private var paths: [ColoredPath] = []  // Store finalized path objects
    // State for robot selection and drawing color
    @State private var selectedRobot: String? = "Robot 1"
    @State private var showBluetoothModal = false 
    @State private var snackbarMessage: String? = nil  // Snackbar message state

    // Define a list of robots with their corresponding colors.
    let robots: [(name: String, color: Color)] = [
        ("Robot 1", .red),
        ("Robot 2", .blue),
        ("Robot 3", .green),
        ("Robot 4", .teal)
    ]
    var body: some View {
        ZStack {
            // Main content
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
                                showBluetoothModal.toggle()
                            }
                        )
                    }
                }
                .padding()

                ZStack {
                    GridOverlayView()
                    SketchCanvasView(drawingColor: $drawingColor, paths: $paths)
                    PathsOverlayView(paths: paths)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ActionBar(paths: $paths)
            }
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $showBluetoothModal) {
                BluetoothModalView(
                    onBluetooth: {
                        showBluetoothModal.toggle()
                    }
                )
            }
            
            // Snackbar overlay
            if let message = snackbarMessage {
                SnackbarView(message: message)
                    .transition(.move(edge: .bottom))
                    .padding(.bottom, 100)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                snackbarMessage = nil
                            }
                        }
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .snackbarMessage)) { notification in
            if let message = notification.object as? String {
                withAnimation {
                    snackbarMessage = message
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
