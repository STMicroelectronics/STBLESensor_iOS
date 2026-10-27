//
//  NodeRowView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STBlueSDK
import STCore
import STUI

struct NodeRowView: View {
    let node: Node
    @ObservedObject var viewModel: NodeDiscoveryViewModel

    private var firmware: Firmware? {
        guard
            let catalogService: CatalogService = Resolver.shared.resolve(),
            let catalog = catalogService.catalog
        else {
            return nil
        }

        return catalog.v2Firmware(
            with: node.deviceId.longHex,
            firmwareId: UInt32(node.bleFirmwareVersion).longHex
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .center) {
                if let uiImage = node.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                }

                VStack(alignment: .leading, spacing: 8) {
                    // MARK: - BOARD NAME - PIN
                    HStack {
                        Text(node.name ?? "Unknown")
                            .applyTextLayout(.title2)

                        Spacer()

                        Button {
                            viewModel.toggleFavorite(node)
                        } label: {
                            Image(systemName:
                                    viewModel.isFavorite(node)
                                  ? "pin.fill"
                                  : "pin")
                            .foregroundColor(
                                viewModel.isFavorite(node) ? SUIColorLayout.yellow.color : SUIColorLayout.stGray3.color
                                )
                        }
                    }

                    // MARK: - FIRMWARE MATURITY
                    if let firmware,
                       firmware.maturity != .release {
                        Text(firmware.maturity?.description ?? "")
                        .applyTextLayout(.infoBold.color(SUIColorLayout.red.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SUIColorLayout.redDark.color.opacity(0.2))
                            .cornerRadius(4)
                    }

                    // MARK: - CUSTOM FIRMWARE - BOARD NAME - RUNNING FIRMWARE - FIRMWARE VERSION
                    if let firmware {
                        if firmware.bleVersionId == 0xff {
                            Text("CUSTOM FIRMWARE")
                                .applyTextLayout(.infoBold.color(SUIColorLayout.redDark.color))
                        }

                        Text("\(firmware.fullName)")
                            .applyTextLayout(.text.color(SUIColorLayout.primary.color))
                    }
                }
            }

            // MARK: - STRING OPTION BYTES
            if let firmware {
                if let first = node.firstExtraMessage(with: firmware) {
                    Text(first)
                        .applyTextLayout(.info)
                }
                if let second = node.secondExtraMessage(with: firmware) {
                    Text(second)
                        .applyTextLayout(.info)
                }
            }

            Divider()

            // MARK: - RSSI - SLEEPING ICON - [IMAGES] OPTION BYTES - MAC ADDRESS
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "cellularbars")
                        .foregroundColor(SUIColorLayout.stGray2.color)
                    Text("\(node.rssi ?? 0)dBm")
                        .applyTextLayout(.text.color(SUIColorLayout.stGray1.color))
                }

                Spacer()

                if node.isSleeping {
                    Image("sleepIcon", bundle: STUI.bundle)
                        .renderingMode(.template)
                        .foregroundColor(SUIColorLayout.stGray2.color)
                }

                Spacer()

                if let firmware {
                    let indexes = node.imageIndexes(with: firmware)

                    HStack(spacing: 8) {
                        ForEach(indexes, id: \.self) { index in
                            if index < 255 {
                                if let image = UIImage(
                                    named: ImageLayout.SDKV2.images[index],
                                    in: STUI.bundle,
                                    with: nil
                                ) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .renderingMode(.template)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(SUIColorLayout.stGray2.color)
                                }
                            }
                        }
                    }
                }

                Spacer()

                Text(node.compoundAddress ?? "")
                    .font(.caption2)
                    .foregroundColor(SUIColorLayout.stGray2.color)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
