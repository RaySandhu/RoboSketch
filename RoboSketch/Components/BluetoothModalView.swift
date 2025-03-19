//
//  BluetoothModalView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//

import SwiftUI

struct BluetoothModalView: View {
    // This is where you add your Bluetooth connection interface.
    var body: some View {
        VStack(spacing: 20) {
            Text("Bluetooth Connection")
                .font(.title2)
                .padding(.top, 20)
            // Add your Bluetooth connection UI elements here.
            Text("Configure your Bluetooth connection here.")
                .padding()

            Button("Close") {
                // Dismissal handled automatically or via @Environment(\.dismiss) in iOS 15+
//                @Environment(\.dismiss)
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
        }
        .padding()
    }
}
