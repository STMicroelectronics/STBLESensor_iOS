//
//  AssetTrackingFallEventView.swift
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

public struct AssetTrackingFallEventView: View {
    
    let event: AssetTrackingFallEventDetected
    let timestamp: String
    
    init (fallEvent: AssetTrackingFallEventDetected, timestamp: String) {
        self.event = fallEvent
        self.timestamp = timestamp
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            
            Image("asset_tracking_event_fall", bundle: STDemos.bundle)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:60.0, height:60.0)
                .padding(16)
           
            VStack(alignment: .leading, spacing: 8) {
                Text(self.timestamp)
                    .font(.system(size: 13.0).weight(.light))
                    .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    .frame(alignment: .leading)
                Text("Fall")
                    .font(.system(size: 13.0).bold())
                    .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    .frame(alignment: .leading)
                Text(String(format: "Height: %.2f cm", self.event.height))
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
