//
//  NodeViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import STUI
import STBlueSDK
import STCore

class NodeViewModel: BaseCellViewModel<Node, NodeCell> {

    override func configure(view: NodeCell) {

        guard let param = param else { return }

        view.customModelLabel.isHidden = true

        view.firmwareLabel.isHidden = true
        view.nodeRunningSecondLabel.isHidden = true
        view.nodeRunningThirdInfoLabel.isHidden = true

        view.isSleepingImageView.isHidden = param.isSleeping
        view.hasExtensionImageView.isHidden = param.hasExtension

        view.nodeRunningImageViews.forEach { imageView in
            imageView.isHidden = true
            imageView.image = nil
        }

        TextLayout.title.apply(to: view.nameLabel)

        TextLayout.info.color(ColorLayout.accent.light).apply(to: view.customModelLabel)
        TextLayout.info.apply(to: view.nodeRunningSecondLabel)
        TextLayout.info.apply(to: view.nodeRunningThirdInfoLabel)
        TextLayout.info.apply(to: view.firmwareLabel)
        TextLayout.info.apply(to: view.rssiLabel)
        TextLayout.info.apply(to: view.addressLabel)
        TextLayout.accentBold.apply(to: view.maturityLabel)

        view.actionButton.setTitle(nil, for: .normal)
        Buttonlayout.imageLayout(image: ImageLayout.Common.pin?.maskWithColor(color: .lightGray),
                                 selectedImage: ImageLayout.Common.pin?.template,
                                 color: ColorLayout.yellow.light).apply(to: view.actionButton)

        view.actionButton.on(.touchUpInside) { button in
            button.isSelected = !button.isSelected
            if let favoritesService: FavoritesService = Resolver.shared.resolve() {
                if button.isSelected {
                    favoritesService.addNodeToFavorites(node: param)
                } else {
                    favoritesService.removeNodeFromFavorites(node: param)
                }
            }
         }

        if let favoritesService: FavoritesService = Resolver.shared.resolve() {
            view.actionButton.isSelected = favoritesService.isFavorite(node: param)
        }

        view.rssiLabel.text = "\(param.rssi ?? 0)dBm"
        view.rssiImageView.contentMode = .center
        view.rssiImageView.image = ImageLayout.Common.signal?
            .scalePreservingAspectRatio(targetSize: ImageSize.extraSmall)
            .maskWithColor(color: .lightGray)
        view.addressLabel.text = param.compoundAddress
        view.customModelLabel.text = Localizer.NodeList.Text.customModel.localized
        view.nodeImageView.contentMode = .scaleAspectFit
        view.nodeImageView.image = param.image

        view.nameLabel.text = param.name

        guard param.protocolVersion == 0x02 else { return }
        guard let catalogService: CatalogService = Resolver.shared.resolve(),
              let catalog = catalogService.catalog else { return }

        if let firmware = catalog.v2Firmware(with: param.deviceId.longHex,
                                          firmwareId: UInt32(param.bleFirmwareVersion).longHex) {

            if firmware.bleVersionId == 255 {
                view.customModelLabel.isHidden = false
            }

            if firmware.maturity != Maturity.release {
                view.maturityLabel.isHidden = false
                view.maturityLabel.text = firmware.maturity?.description
            }

            view.firmwareLabel.isHidden = false
            view.firmwareLabel.text = firmware.fullName

            let firstLineMessage = param.firstExtraMessage(with: firmware)
            let secondLineMessage = param.secondExtraMessage(with: firmware)

            let imageIndexes = param.imageIndexes(with: firmware)

            view.nodeRunningSecondLabel.isHidden = firstLineMessage == nil
            view.nodeRunningThirdInfoLabel.isHidden = secondLineMessage == nil

            view.nodeRunningSecondLabel.text = firstLineMessage
            view.nodeRunningThirdInfoLabel.text = secondLineMessage

            for (index, imageIndex) in imageIndexes.enumerated() {
                view.nodeRunningImageViews[index].contentMode = .center
                view.nodeRunningImageViews[index].isHidden = false
                if imageIndex < 255 {
                    view.nodeRunningImageViews[index].image = ImageLayout.image(
                        with: ImageLayout.SDKV2.images[imageIndex],
                        in: STUI.bundle)?
                        .scalePreservingAspectRatio(targetSize: ImageSize.extraSmall)
                        .maskWithColor(color: .lightGray)
                }
            }
        }

    }

}
