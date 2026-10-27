//
//  SUINoResultView.swift
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

struct SUINoResultView: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: 10.0) {
            Image("img_discover_no_result", bundle: STUI.bundle)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 220)

            Text(Localizer.Home.NoResultView.Text.title.localized)
                .applyTextLayout(.title)
                .multilineTextAlignment(.center)

            Text(Localizer.Home.NoResultView.Text.description.localized)
                .applyTextLayout(.info)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            Button(action: action) {
                Text("DISCOVER OUR PRODUCTS")
            }
            .applyButtonLayout(.standard.with(fullWidth: true))
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
