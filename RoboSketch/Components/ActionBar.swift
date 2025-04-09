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
            print("File exists at: \(fileURL.path)")
        } else {
            print("File does NOT exist at: \(fileURL.path)")
        }
    }
    
    func generatePythonScript(from paths: [ColoredPath]) {
        var scriptLines = [String]()
        // Header and initialization
        scriptLines.append("from picrawler import Picrawler")
        scriptLines.append("from time import sleep")
        scriptLines.append("")
        // Instantiate PiCrawler with default servo indices (adjust if needed)
        scriptLines.append("crawler = Picrawler([10,11,12,4,5,6,1,2,3,7,8,9])")
        scriptLines.append("speed = 80")
        scriptLines.append("")
        scriptLines.append("def main():")
        
        // For each ColoredPath, decode its stored JSON encoding and generate commands.
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
                    if let commands = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for command in commands {
                            guard let cmd = command["cmd"] as? String,
                                  let points = command["points"] as? [[String: Any]] else { continue }
                            
                            if cmd == "moveTo" {
                                // For moveTo, we just note the starting point.
                                if let pt = points.first,
                                   let x = pt["x"],
                                   let y = pt["y"] {
                                    scriptLines.append("    # Starting point from moveTo: (\(x), \(y))")
                                }
                            } else if cmd == "lineTo" {
                                // For a lineTo segment, iterate over each point.
                                scriptLines.append("    # Begin lineTo segment")
                                // In a more advanced generator, you’d compute turning angles and forward distances.
                                // Here we simulate movement by a forward command for each point.
                                for pt in points {
                                    if let x = pt["x"], let y = pt["y"] {
                                        scriptLines.append("    # Move toward point (\(x), \(y))")
                                        scriptLines.append("    crawler.do_action('forward', 1, speed)")
                                        scriptLines.append("    sleep(0.05)")
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
        
        // End the script by standing
        scriptLines.append("    crawler.do_step('stand', speed)")
        scriptLines.append("    sleep(1)")
        scriptLines.append("")
        scriptLines.append("if __name__ == '__main__':")
        scriptLines.append("    main()")
        
        // Join the lines into a single script string.
        let script = scriptLines.joined(separator: "\n")
        
        // Save the generated script to the Documents directory.
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("generated_script.py")
            do {
                try script.write(to: fileURL, atomically: true, encoding: .utf8)
                print("Python script generated at: \(fileURL)")
                // Copy the script to the clipboard.
                UIPasteboard.general.string = script
                print("Script copied to clipboard.")
            } catch {
                print("Error writing Python script: \(error)")
            }
        }
    }
}
