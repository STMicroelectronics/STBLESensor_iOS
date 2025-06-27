//
//  LegacyView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import SwiftUI
import STUI

public struct LegacyView: View {
    public var body: some View {
        
        VStack(spacing: 16) {
            Text("Demo is NOT Supported")
                .font(.stTitle)
                .foregroundColor(ColorLayout.text.auto.swiftUIColor)
            
            Image(.stblesensorclassicicon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("ST BLE Sensor Classic")
                .font(.stTitle2)
                .foregroundColor(ColorLayout.text.auto.swiftUIColor)
            
            Text("This demo is not supported. Please download and use the ST BLE Sensor Classic version.\nClick on the badge below.")
                .font(.stInfo)
                .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                .multilineTextAlignment(.center)
            
            Image(.appstorebadge)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .onTapGesture {
                    if let url = URL(string: "https://apps.apple.com/it/app/st-ble-sensor-classic/id6447749695") {
                        UIApplication.shared.open(url)
                    }
                }
        }
        .padding()
    }
}

#Preview {
    LegacyView()
}
