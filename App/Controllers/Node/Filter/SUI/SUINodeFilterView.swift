//
//  SUINodeFilterView.swift
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

struct SUINodeFilterView: View {

    @State private var sliderValue: Double
    let onValueChanged: (Int) -> Void
    let onDismiss: () -> Void

    init(currentValue: Int,
         onValueChanged: @escaping (Int) -> Void,
         onDismiss: @escaping () -> Void) {
        _sliderValue = State(initialValue: Double(-currentValue))
        self.onValueChanged = onValueChanged
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("RSSI Filter")
                    .applyTextLayout(.title)
                    .multilineTextAlignment(.leading)
                Spacer()
            }

            HStack {
                Text("-4 dBm")

                Slider(value: $sliderValue, in: 4...100, step: 1)
                    .tint(SUIColorLayout.secondary.color)
                    .onChange(of: sliderValue) { _, newValue in
                        let value = -Int(newValue)
                        onValueChanged(value)
                    }

                Text("-100 dBm")
            }

            Text("\(-Int(sliderValue)) dBm")
                .font(.subheadline)
        }
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
