import SwiftUI
extension Color {
    var name: String {
        // Adjust these names as needed.
        if self == .red { return "red" }
        else if self == .blue { return "blue" }
        else if self == .green { return "green" }
        else if self == .teal { return "teal" }
        return "unknown"
    }
}

struct ActionBar: View {
    @Binding var paths: [ColoredPath]
    @State private var undone: [ColoredPath] = []
    @Binding var clearSignal: Bool

    var body: some View {
        HStack {
            Button("Save") {
                if paths.count > 0 {
                    savePaths()
                } else{
                    NotificationCenter.default.post(name: .snackbarMessage,
                                                    object: "Nothing to save!")
                }
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: paths.count == 0 ? .gray : .orange))
            
            Button("Redo") {
                if let lastUndone = undone.popLast() {
                    paths.append(lastUndone)
                }else{
                    NotificationCenter.default.post(name: .snackbarMessage,
                                                    object: "Nothing to redo!")
                }
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: undone.count == 0 ? .gray : .yellow))
            
            Button("Undo") {
                if let last = paths.popLast() {
                    undone.append(last)
                }else{
                    NotificationCenter.default.post(name: .snackbarMessage,
                                                    object: "Nothing to undo!")
                }
            }
            .disabled(paths.isEmpty)
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: paths.count == 0 ? .gray : .blue))
            
            Button("Clear") {
                paths.removeAll()
                undone.removeAll()
                clearSignal.toggle() // Triggers PKCanvasView to clear
            }
            .disabled(paths.isEmpty)
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: paths.count == 0 ? .gray : .red))
            
            Button("Play") {
                generatePythonScript(from: paths)
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .green))
        }
        .background(Color(UIColor.systemGray6))
    }
    
    func savePaths() {
        print("Number of paths to save: \(paths.count) \(paths[0].encodedPath)")
        
        // Locate the documents directory on the device.
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found.")
            return
        }
        
        // Specify the file URL (e.g., "paths.json").
        let fileURL = documentsDirectory.appendingPathComponent("paths.json")
        
        // Create an array to hold all the path dictionaries.
        var pathsArray: [[String: Any]] = []
        
        // Iterate over each ColoredPath.
        for coloredPath in paths {
            let encodedPathString = coloredPath.encodedPath
            if let data = encodedPathString.data(using: .utf8) {
                if let encodingObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                    let pathDict: [String: Any] = [
                        "color": coloredPath.color.name,
                        "encoding": encodingObject
                    ]
                    //                    print("Number of paths to save: \(paths.count) \(coloredPath.encodedPath)")
                    print(pathDict)
                    pathsArray.append(pathDict)
                } else {
                    print("Failed to convert encodedPath string into a JSON object")
                }
            } else {
                print("Failed to convert encodedPath to Data")
            }
        }
        
        
        
        // Convert the array into JSON data.
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: pathsArray, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
            print("Paths saved to: \(fileURL)")
        } catch {
            print("Error saving paths: \(error)")
        }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("Python script generated at: \(fileURL.path)".replacingOccurrences(of: " ", with: "\\ "))
        } else {
            print("File does NOT exist at: \(fileURL.path)")
        }
    }
    
    func generatePythonScript(from paths: [ColoredPath]) {
        var scriptLines = [String]()
        
        // Header and initialization (using your picrawler syntax)
        scriptLines.append("from spider import Spider")
        scriptLines.append("from ezblock import print, delay")
        scriptLines.append("")
        scriptLines.append("crawler = Spider([10,11,12,4,5,6,1,2,3,7,8,9])")
        scriptLines.append("speed = 1000")
        scriptLines.append("")
        scriptLines.append("def main():")
        
        // Iterate over each ColoredPath
        for coloredPath in paths {
            // We assume encodedPath is a non-optional String property of ColoredPath.
            //let encoded = coloredPath.encodedPath
            let encoded = coloredPath.encodedPath.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !encoded.isEmpty else {
                print("Skipping path with empty encodedPath.")
                continue
            }
            if let data = encoded.data(using: .utf8) {
                do {
                    // Assuming the top-level JSON is an array of command dictionaries.
                    if let commands = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for command in commands {
                            guard let cmd = command["cmd"] as? String,
                                  let points = command["points"] as? [[String: Any]] else { continue }
                            
                            if cmd == "moveTo" {
                                // Process the "moveTo" command as the starting point.
                                if let pt = points.first,
                                   let x = pt["x"] as? Double,
                                   let y = pt["y"] as? Double {
                                    scriptLines.append("    # Starting point at (\(x), \(y))")
                                    scriptLines.append("    crawler.do_action(\"move\", 1, speed)")
                                    scriptLines.append("    delay(50)")
                                }
                            } else if cmd == "lineTo" {
                                // Process the "lineTo" commands with turn calculations.
                                scriptLines.append("    # Begin lineTo segment")
                                var previousPoint: (x: Double, y: Double)? = nil
                                var previousHeading: Double? = nil
                                
                                // Iterate over each point in the "lineTo" segment.
                                for pt in points {
                                    if let x = pt["x"] as? Double,
                                       let y = pt["y"] as? Double {
                                        if let prev = previousPoint {
                                            // Calculate heading (in degrees) from the previous point to the current point.
                                            let dx = x - prev.x
                                            let dy = y - prev.y
                                            let currentHeading = atan2(dy, dx) * 180.0 / Double.pi
                                            
                                            if let prevHeading = previousHeading {
                                                // Calculate the delta between headings,
                                                // normalized to the range [-180, 180].
                                                let deltaAngle = fmod(currentHeading - prevHeading + 180.0, 360.0) - 180.0
                                                
                                                // Only consider turns if the change is at least 20°.
                                                if abs(deltaAngle) >= 20.0 {
                                                    // Each 35° of turn corresponds to one step.
                                                    let turnSteps = Int(round(abs(deltaAngle) / 25.0))
                                                    
                                                    if deltaAngle < 0 {
                                                        // Positive delta: "turn left angle" command.
                                                        scriptLines.append("    # Turn left by \(turnSteps) (approx \(turnSteps*35)°)")
                                                        scriptLines.append("    crawler.do_action(\"turn left angle\", \(turnSteps), speed)")
                                                    } else {
                                                        // Negative delta: "turn right angle" command.
                                                        scriptLines.append("    # Turn right by \(turnSteps) (approx \(turnSteps*35)°)")
                                                        scriptLines.append("    crawler.do_action(\"turn right angle\", \(turnSteps), speed)")
                                                    }
                                                    scriptLines.append("    delay(50)")
                                                }
                                            }
                                            // Update the previous heading for the next segment.
                                            previousHeading = atan2(y - prev.y, x - prev.x) * 180.0 / Double.pi
                                        }
                                        // Set the current point as the previous point.
                                        previousPoint = (x, y)
                                        
                                        // Append the forward movement command.
                                        scriptLines.append("    # Move toward point (\(x), \(y))")
                                        scriptLines.append("    crawler.do_action(\"forward\", 1, speed)")
                                        scriptLines.append("    delay(50)")
                                    }
                                }
                            } else {
                                scriptLines.append("    # Unknown command: \(cmd)")
                            }
                        }
                    } else {
                        print("Failed to decode JSON as an array for a path.")
                    }
                } catch {
                    print("Error decoding encodedPath: \(error)")
                }
            } else {
                print("Could not convert encodedPath to Data.")
            }
        }
        
        // End the script with the stand command.
        scriptLines.append("    crawler.do_action(\"stand\", 1, speed)")
        scriptLines.append("")
        scriptLines.append("def forever():")
        scriptLines.append("    main()")
        
        // Join the generated lines into a single Python script.
        let script = scriptLines.joined(separator: "\n")
        
        // Save the generated script to the Documents directory.
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("generated_script.py")
            do {
                try script.write(to: fileURL, atomically: true, encoding: .utf8)
                print("code \(fileURL)".replacingOccurrences(of: "%20", with: "\\ ").replacingOccurrences(of: "file://", with: ""))
                // Optionally, copy the script to the clipboard.
                UIPasteboard.general.string = script
                print("Script copied to clipboard.")
            } catch {
                print("Error writing Python script: \(error)")
            }
        }
    }
}
