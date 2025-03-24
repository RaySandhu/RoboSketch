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
    @State private var undone: ColoredPath?

    var body: some View {
        HStack {
            Button("Save") {
                savePaths()
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .orange))
            
            Button("Redo") {
                if let undone = undone {
                    paths.append(undone)
                    self.undone = nil
                }
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .yellow))
            
            Button("Undo") {
                undone = paths.popLast()
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .blue))
            
            Button("Clear") {
                paths = []
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .red))
            
            Button("Play") {
                // TODO: Play action here
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
}
