//
//  NodeHeaderView.swift
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
import STBlueSDK

struct NodeHeaderView: View {

    @StateObject private var viewModel: SUINodeHeaderViewModel

    init(node: Node) {
        _viewModel = StateObject(wrappedValue: SUINodeHeaderViewModel(node: node))
    }

    var body: some View {

        VStack(spacing: 10) {

            Text(viewModel.node.name ?? "Board")
                .applyTextLayout(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)

            if let image = viewModel.node.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
            }

            if let firmwareFullName = viewModel.firmwareFullName {

                Divider()

                Text(firmwareFullName)
                    .applyTextLayout(.info)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
            }

            if let customDtmiText = viewModel.customDtmiText {

                Text(customDtmiText)
                    .applyTextLayout(.infoBold.color(viewModel.customDtmiColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
            }
        }
        .padding(.horizontal, 20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 4)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
