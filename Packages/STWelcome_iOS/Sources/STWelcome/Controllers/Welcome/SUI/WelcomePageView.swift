//
//  WelcomePageView.swift
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

struct WelcomePageView: View {

    let page: WelcomePage

    var body: some View {
        VStack(spacing: 16) {

            page.image?
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .infinity)
            
            Spacer()

            if let title = page.title {
                Text(title)
                    .applyTextLayout(.title2)
                    .multilineTextAlignment(.center)
            }

            if let content = page.content {
                Text(content)
                    .applyTextLayout(.info)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
