//
//  NodeView.swift
//  RoboSketch
//
//  Created by Jarin Thundathil on 2025-04-02.

//import SwiftUI
//
//struct NodeView: View {
//    var node: Node
//    var position: CGPoint
//    var color: Color
//
//    @State private var isActive = false
//    @State private var showDropdown = false
//
//    let options = ["Dance", "Spin", "Wave"]
//
//    var body: some View {
//        ZStack {
//            // Fullscreen invisible background to dismiss dropdown on tap
//            if showDropdown {
//                Color.clear
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        withAnimation {
//                            showDropdown = false
//                            isActive = false
//                        }
//                    }
//            }
//
//            // Node + anchored dropdown menu
//            ZStack(alignment: .top) {
//                // Dropdown menu positioned below node
//                if showDropdown {
//                    VStack(spacing: 0) {
//                        Spacer().frame(height: 32) // push menu below node
//                        VStack(spacing: 0) {
//                            ForEach(options, id: \.self) { option in
//                                Button(action: {
//                                    withAnimation {
//                                        showDropdown = false
//                                        isActive = false
//                                    }
//                                    print("Selected option: \(option)")
//                                }) {
//                                    Text(option)
//                                        .font(.system(size: 16, weight: .medium))
//                                        .foregroundColor(.black)
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        .padding(.vertical, 10)
//                                        .padding(.horizontal, 16)
//                                        .background(Color.white)
//                                        .contentShape(Rectangle())
//                                }
//                                .buttonStyle(PlainButtonStyle())
//                                .overlay(
//                                    Rectangle()
//                                        .frame(height: 1)
//                                        .foregroundColor(Color.gray.opacity(0.15)),
//                                    alignment: .bottom
//                                )
//                            }
//                        }
//                        .frame(width: 140)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
//                                .background(Color.white.cornerRadius(10))
//                        )
//                        .shadow(radius: 4)
//                        .transition(.opacity.combined(with: .move(edge: .top)))
//                    }
//                }
//
//                // Node stays in fixed position
//                Circle()
//                    .fill(color)
//                    .frame(width: isActive ? 22 : 16, height: isActive ? 22 : 16)
//                    .scaleEffect(showDropdown ? 1.1 : 1.0)
//                    .animation(.easeInOut(duration: 0.2), value: showDropdown)
//                    .onTapGesture {
//                        withAnimation {
//                            isActive.toggle()
//                            showDropdown.toggle()
//                        }
//                    }
//                    .padding(10)
//                    .contentShape(Rectangle())
//            }
//        }
//        .position(position)
//        .zIndex(showDropdown ? 1 : 0)
//    }
//}


import SwiftUI

struct NodeView: View {
    var node: Node
    var position: CGPoint
    var color: Color

    @State private var isActive = false
    @State private var showDropdown = false

    let options = [
        "Dance",
        "Spin",
        "Wave",
        "Wait",
        "Look up & down",
        "Turn around",
        "Play sad music"
    ]

    var body: some View {
        ZStack {
            // Fullscreen invisible background to dismiss dropdown on tap
            if showDropdown {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            showDropdown = false
                            isActive = false
                        }
                    }
            }

            // Node + anchored dropdown menu
            ZStack(alignment: .top) {
                // Dropdown menu positioned below node
                if showDropdown {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 32) // push menu below node
                        VStack(spacing: 0) {
                            ForEach(options, id: \.self) { option in
                                Button(action: {
                                    withAnimation {
                                        showDropdown = false
                                        isActive = false
                                    }
                                    print("Selected option: \(option)")
                                }) {
                                    Text(option)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .background(Color.white)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(Color.gray.opacity(0.15)),
                                    alignment: .bottom
                                )
                            }
                        }
                        .frame(width: 180)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                .background(Color.white.cornerRadius(10))
                        )
                        .shadow(radius: 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                // Node stays in fixed position
                Circle()
                    .fill(color)
                    .frame(width: isActive ? 22 : 16, height: isActive ? 22 : 16)
                    .scaleEffect(showDropdown ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showDropdown)
                    .onTapGesture {
                        withAnimation {
                            isActive.toggle()
                            showDropdown.toggle()
                        }
                    }
                    .padding(10)
                    .contentShape(Rectangle())
            }
        }
        .position(position)
        .zIndex(showDropdown ? 1 : 0)
    }
}
