//
//  AssetTrackingShockEventView.swift
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
import STBlueSDK

public struct AssetTrackingShockEventView: View {

    let event: AssetTrackingShockEventDetected
    let timestamp: String
    
    init (shockEvent: AssetTrackingShockEventDetected, timestamp: String) {
        self.event = shockEvent
        self.timestamp = timestamp
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            
            Image("asset_tracking_event_shock", bundle: STDemos.bundle)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:60.0, height:60.0)
                .padding(16)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(self.timestamp)
                        .font(.system(size: 13.0).weight(.light))
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        .frame(alignment: .leading)
                    Spacer()
                    ImageLayout.SUICommon.infoFilled?.resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(ColorLayout.primary.auto.swiftUIColor)
                }
                Text("Shock")
                    .font(.system(size: 13.0).bold())
                    .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    .frame(alignment: .leading)
                Text(String(format: "Duration: %.2f mSec", self.event.duration))
                    .font(.system(size: 13.0).weight(.light))
                    .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    .frame(alignment: .leading)
                Text(String(format: "Intensity: %.2f g", self.event.intensityNorm))
                    .font(.system(size: 13.0).weight(.light))
                    .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    .frame(alignment: .leading)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity ,alignment: .leading)
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .padding(8)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}


