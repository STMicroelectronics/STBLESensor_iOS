//
//  AssetTrackingShockCubeView.swift
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
import STBlueSDK
import STUI

struct ShockCubeView: View {
    let item: AssetTrackingShockEventDetected

    var body: some View {

        ZStack {
            GeometryReader { geometry in
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2

                let axisColors = evaluateAxisColors(item.orientation)
                
                // Cubo centrale
                Image("asset_tracking_event_cube", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .position(x: centerX, y: centerY)
                    .foregroundColor(ColorLayout.secondary.auto.swiftUIColor)

                // +Z (in alto)
                Image("asset_tracking_event_plus_z", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 45, height: 45)
                    .position(x: centerX, y: centerY - 45)
                    .foregroundColor(axisColors.zPlusAxisColor)

                // -Z (in basso)
                Image("asset_tracking_event_minus_z", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .position(x: centerX, y: centerY + 53)
                    .foregroundColor(axisColors.zMinusAxisColor)

                // +X (diagonale in basso a destra)
                Image("asset_tracking_event_plus_x", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .position(x: centerX + 40, y: centerY + 25)
                    .foregroundColor(axisColors.xPlusAxisColor)

                // -X (diagonale in alto a sinistra)
                Image("asset_tracking_event_minus_x", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .position(x: centerX - 50, y: centerY - 35)
                    .foregroundColor(axisColors.xMinusAxisColor)

                // +Y (diagonale in alto a destra)
                Image("asset_tracking_event_plus_y", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 45, height: 45)
                    .position(x: centerX + 55, y: centerY - 25)
                    .foregroundColor(axisColors.yPlusAxisColor)

                // -Y (diagonale in basso a sinistra)
                Image("asset_tracking_event_minus_y", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .position(x: centerX - 45, y: centerY + 25)
                    .foregroundColor(axisColors.yMinusAxisColor)
            }
        }
        .frame(width: 200, height: 200)
    }
    
    private func evaluateAxisColors(_ orientation: [AssetTrackingOrientationType]) -> ShockCubeAxisColor {
        var xPlusAxisColor = ColorLayout.primary.auto.swiftUIColor
        var xMinusAxisColor = ColorLayout.primary.auto.swiftUIColor
        var yPlusAxisColor = ColorLayout.primary.auto.swiftUIColor
        var yMinusAxisColor = ColorLayout.primary.auto.swiftUIColor
        var zPlusAxisColor = ColorLayout.primary.auto.swiftUIColor
        var zMinusAxisColor = ColorLayout.primary.auto.swiftUIColor
        
        if orientation.count >= 3 {
            let currentXorientation = orientation[0]
            let currentYorientation = orientation[1]
            let currentZorientation = orientation[2]
            
            if currentXorientation == .positive {
                xPlusAxisColor = ColorLayout.greenDark.auto.swiftUIColor
            } else if currentXorientation == .negative {
                xMinusAxisColor = ColorLayout.redDark.auto.swiftUIColor
            }
            
            if currentYorientation == .positive {
                yPlusAxisColor = ColorLayout.greenDark.auto.swiftUIColor
            } else if currentYorientation == .negative {
                yMinusAxisColor = ColorLayout.redDark.auto.swiftUIColor
            }
            
            if currentZorientation == .positive {
                zPlusAxisColor = ColorLayout.greenDark.auto.swiftUIColor
            } else if currentZorientation == .negative {
                zMinusAxisColor = ColorLayout.redDark.auto.swiftUIColor
            }
            
            return ShockCubeAxisColor(
                xPlusAxisColor: xPlusAxisColor,
                xMinusAxisColor: xMinusAxisColor,
                yPlusAxisColor: yPlusAxisColor,
                yMinusAxisColor: yMinusAxisColor,
                zPlusAxisColor: zPlusAxisColor,
                zMinusAxisColor: zMinusAxisColor)
        } else {
            return ShockCubeAxisColor(
                xPlusAxisColor: ColorLayout.primary.auto.swiftUIColor,
                xMinusAxisColor: ColorLayout.primary.auto.swiftUIColor,
                yPlusAxisColor: ColorLayout.primary.auto.swiftUIColor,
                yMinusAxisColor: ColorLayout.primary.auto.swiftUIColor,
                zPlusAxisColor: ColorLayout.primary.auto.swiftUIColor,
                zMinusAxisColor: ColorLayout.primary.auto.swiftUIColor)
        }
    }
    
    private struct ShockCubeAxisColor {
        let xPlusAxisColor: Color
        let xMinusAxisColor: Color
        let yPlusAxisColor: Color
        let yMinusAxisColor: Color
        let zPlusAxisColor: Color
        let zMinusAxisColor: Color
    }
}
