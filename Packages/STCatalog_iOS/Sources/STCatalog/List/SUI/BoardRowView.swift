//
//  BoardRowView.swift
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

public struct BoardRowView: View {

    public let board: Board

    public init(board: Board) {
        self.board = board
    }

    public var body: some View {
        HStack(spacing: 0) {
            thumbnail
            details
        }
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(radius: 8, y: 4)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }

    private var thumbnail: some View {
        ZStack {
            Color(SUIColorLayout.stGray5.color).opacity(0.5)

            if let image = board.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
            }
        }
        .frame(width: 100, height: 220)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(board.name)
                .applyTextLayout(SUITextLayout.title2).fontWeight(.semibold)
                .padding(.top, 10)

            if let friendlyName = board.friendlyName {
                Text(friendlyName)
                    .applyTextLayout(.text)
            }

            if let description = board.description {
                Text(description)
                    .applyTextLayout(.info)
            }

            Spacer(minLength: 0)
            
            if let status = board.status {
                Text(status)
                    .foregroundStyle(status == "NRND"
                                     ? SUIColorLayout.red.color
                                     : SUIColorLayout.green.color)
                    .applyTextLayout(.infoBold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
