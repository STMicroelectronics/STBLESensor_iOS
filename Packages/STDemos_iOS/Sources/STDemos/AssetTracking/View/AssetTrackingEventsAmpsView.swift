//
//  AssetTrackingEventsAmpsView.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STUI

struct AssetTrackingEventsAmpsView: View {
    let currentMicroAmps: Int
    let powerIndex: Int
    
    let totalBlocks = 10
    let greenBlocks = 3
    let yellowBlocks = 3
    let ochreBlocks = 2
    let redBlocks = 2
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Amps:")
                .font(.system(size: 14.0).weight(.light))
                .foregroundColor(ColorLayout.text.auto.swiftUIColor)
        
            Text("\(currentMicroAmps) [µA]")
                .font(.system(size: 14.0).weight(.bold))
                .foregroundColor(ColorLayout.text.auto.swiftUIColor)

            Spacer()
            
            HStack(spacing: 4) {
                ForEach(0..<totalBlocks, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 12, height: 20)
                        .foregroundColor(index < powerIndex ? color(for: index) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
            }
        }
    }

    func color(for index: Int) -> Color {
        switch index {
        case 0..<greenBlocks:
            return ColorLayout.green.auto.swiftUIColor
        case greenBlocks..<(greenBlocks + yellowBlocks):
            return ColorLayout.yellow.auto.swiftUIColor
        case (greenBlocks + yellowBlocks)..<(greenBlocks + yellowBlocks + ochreBlocks):
            return ColorLayout.ochre.auto.swiftUIColor
        case (greenBlocks + yellowBlocks + ochreBlocks)..<totalBlocks:
            return ColorLayout.redDark.auto.swiftUIColor
        default:
            return .clear
        }
    }
}
