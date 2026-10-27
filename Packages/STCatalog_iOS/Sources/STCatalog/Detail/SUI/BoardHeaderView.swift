//
//  BoardHeaderView.swift
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

struct BoardHeaderView: View {

    let board: Board
    let firmwareFilter: FirmwareFilter
    
    let datasheetHandler: () -> Void
    
    private var isFirmwareEnabled: Bool {
        !(board.characteristics?.isEmpty ?? true)
    }

    private var isDatasheetEnabled: Bool {
        board.datasheetsUrl != nil
    }

    var body: some View {

        VStack(spacing: 0) {

            VStack(alignment: .leading,spacing: 12) {

                VStack(alignment: .leading, spacing: 8) {

                    Text(board.name)
                        .applyTextLayout(.title2)

                    if let friendlyName = board.friendlyName {
                        Text(friendlyName)
                            .font(.system(size: 16))
                    }

                    if let status = board.status {
                        Text(status)
                            .foregroundColor(
                                status == "NRND"
                                ? SUIColorLayout.red.color
                                : SUIColorLayout.green.color
                            )
                            .applyTextLayout(.infoBold)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let image = board.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(
                            SUIColorLayout.systemWhite.color
                        )
                }
            }
            .padding()

            Divider()

            HStack(spacing: 0) {
                
                NavigationLink {
                    FirmwareListView(filter: firmwareFilter)
                } label: {
                    Text(Localizer.CatalogDetail.Action.firmware.localized)
                }
                .disabled(!isFirmwareEnabled)
                .applyButtonLayout(.textSecondaryColor.with(fullWidth: true))

                Divider()
                    .frame(width: 1)

                Button(
                    Localizer.CatalogDetail.Action.datasheets.localized,
                    action: datasheetHandler
                )
                .disabled(!isDatasheetEnabled)
                .applyButtonLayout(.textSecondaryColor.with(fullWidth: true))
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 4)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
