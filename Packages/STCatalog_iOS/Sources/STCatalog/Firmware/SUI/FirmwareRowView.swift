//
//  FirmwareRowView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STUI
import STDemos
import STBlueSDK

struct FirmwareRowView: View {
    let firmware: Firmware

    private var maturityText: String? {
        if firmware.bleVersionId == 0xFF {
            return Maturity.custom.description
        }
        if let maturity = firmware.maturity, maturity != .release {
            return maturity.description
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(firmware.name)
                .applyTextLayout(.title2)

            Text(firmware.version)
                .applyTextLayout(.text.color(SUIColorLayout.primary.color))

            if let maturityText {
                Text(maturityText)
                    .applyTextLayout(.infoBold)
            }

            Text(firmware.description ?? "--")
                .applyTextLayout(.info)

            Divider()
                .frame(height: 1)
                .background(SUIColorLayout.stGray5.light)

            Text("Available Demos")
                .applyTextLayout(.infoBold.color(SUIColorLayout.primary.color))

            Text(firmware.availableDemosString)
                .applyTextLayout(.info)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
