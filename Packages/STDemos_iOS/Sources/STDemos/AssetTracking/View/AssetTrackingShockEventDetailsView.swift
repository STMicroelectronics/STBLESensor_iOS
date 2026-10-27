//
//  AssetTrackingShockEventDetailsView.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import Foundation
import STUI

struct ShockEventDetailsDialogView: View {
    let item: AssetTrackingShockEventDetected
    @Binding var isVisible: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Shock Event Details")
                .font(.system(size: 18.0).bold())
                .foregroundColor(ColorLayout.primary.auto.swiftUIColor)
            Divider()

            if (!item.orientation.isEmpty) {
                ShockCubeView(item: self.item)
            }
            
            if (!item.intensity.isEmpty) {
                HStack (spacing: 8) {
                    Text("Acc [g]")
                        .font(.system(size: 13.0).bold())
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("X")
                            .font(.system(size: 13.0).bold())
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        Text(String(format: "%.2f", item.intensity[0]))
                            .font(.system(size: 13.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("Y")
                            .font(.system(size: 13.0).bold())
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        Text(String(format: "%.2f", item.intensity[1]))
                            .font(.system(size: 13.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("Z")
                            .font(.system(size: 13.0).bold())
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        Text(String(format: "%.2f", item.intensity[2]))
                            .font(.system(size: 13.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    }
                    .frame(maxWidth: .infinity)
                    
                }
                
            }
            
            if (!item.angles.isEmpty) {
                Divider()
                    .frame(height: 2)
                    .background(ColorLayout.primary.auto.swiftUIColor)

                HStack (spacing: 8) {
                    
                    Text("Angle [°]")
                        .font(.system(size: 13.0).bold())
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("X")
                            .font(.system(size: 13.0).bold())
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        Text(String(format: "%.2f", item.angles[0]))
                            .font(.system(size: 13.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                    VStack {
                        Text("Y")
                            .font(.system(size: 13.0).bold())
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        Text(String(format: "%.2f", item.angles[1]))
                            .font(.system(size: 13.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("Z")
                            .font(.system(size: 13.0).bold())
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        Text(String(format: "%.2f", item.angles[2]))
                            .font(.system(size: 13.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    }
                    .frame(maxWidth: .infinity)
                }
            
            }
            
            HStack {
                Spacer()
                Button(action: {
                    isVisible = false
                }) {
                    Text("OK")
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
//                        .frame(maxWidth: .infinity)
                        .frame(width: 120)
                        .background(ColorLayout.primary.auto.swiftUIColor)
                        .cornerRadius(8)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
