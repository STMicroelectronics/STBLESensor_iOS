//
//  FlashBankStatusPresenter+Layout.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import STCore

extension FlashBankStatusPresenter {
    func configureHeaderViewmodels() {
        let layout = Layout.standard.backgroundColor(backgroundColor: ColorLayout.primary)
        let subtitle = layout.text(textLayout: layout.textLayout?.weight(.bold).color(ColorLayout.systemWhite.light))
        //let text = layout.text(textLayout: layout.textLayout?.alignment(.center).size(12.0))
        let textWhite = layout.text(textLayout: layout.textLayout?
            .alignment(.center)
            .weight(.light)
            .size(12.0)
            .color(ColorLayout.systemWhite.light)
        )
        let textLeftWhite = layout.text(textLayout: layout.textLayout?
            .alignment(.left)
            .weight(.light)
            .size(12.0)
            .color(ColorLayout.systemWhite.light)
        )

        director?.elements.append(
            TableDirector.label(
                with: Localizer.Firmware.Text.bankStatus.localized(with: [ param.bankStatus.currentBank ]),
                layout: textLeftWhite,
                image: ImageLayout.Common.info?.scalePreservingAspectRatio(targetSize: ImageSize.small).withTintColor(ColorLayout.systemWhite.light),
                tapHandler: { [weak self] _ in
                    guard let self else { return }
                    UIAlertController.presentAlert(
                        from: self.view,
                        title: Localizer.Common.warning.localized,
                        message: Localizer.Firmware.Text.firmwareCurrentBankInfo.localized,
                        actions: [ UIAlertAction.genericButton() ]
                    )
                }
            )
        )

        director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.currentRunningFirmware.localized,
                                                      layout: subtitle))

        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let firmwareName = catalogService.catalog?.v2Firmware(with: param.node)?.compoundName {
            director?.elements.append(TableDirector.label(with: firmwareName,
                                                          layout: textWhite))
        } else {
            director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.firmwareUnknown.localized,
                                                          layout: textWhite))
        }

        let whiteLayout = Layout.standard
        let whiteSubtitle = whiteLayout.text(textLayout: layout.textLayout?.weight(.bold))
        let whiteText = whiteLayout.text(textLayout: whiteLayout.textLayout?.alignment(.center).size(12.0))

        director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.otherBankStatus.localized,
                                                      layout: whiteLayout,
                                                      image: ImageLayout.Common.info?.scalePreservingAspectRatio(targetSize: ImageSize.small),
                                                      tapHandler: { [weak self] _ in

            guard let self else { return }

            UIAlertController.presentAlert(from: self.view,
                                           title: Localizer.Common.warning.localized,
                                           message: Localizer.Firmware.Text.firmwareOtherBankInfo.localized,
                                           actions: [ UIAlertAction.genericButton() ])
        }))

        director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.firmwarePresent.localized,
                                                      layout: whiteSubtitle))

        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let firmwareName = catalogService.catalog?.v2Firmware(with: param.node.deviceId.longHex,
                                                                     firmwareId: param.bankStatus.fwId2.lowercased(),
                                                                     checkCustomFirmware: false)?.compoundName {
            director?.elements.append(TableDirector.label(with: firmwareName,
                                                          layout: whiteText))
        } else {
            director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.firmwareUnknown.localized,
                                                          layout: whiteText))
        }
    }

    func configureAvailableUpdateViewmodels() {
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let current = catalogService.catalog?.v2Firmware(with: param.node),
           let availableUpdate = catalogService.catalog?.mostRecentAvailableNewV2Firmware(with: param.node.deviceId.longHex,
                                                                                              currentFirmware: current) {

            selectedFirmware = availableUpdate

            let layout = Layout.standard
            let title = layout.text(textLayout: layout.textLayout?.weight(.bold))

            let textLeftAligned = layout.text(textLayout: layout.textLayout?.alignment(.left).size(12.0))
            let textCentered = layout.text(textLayout: layout.textLayout?
                .alignment(.center)
                .weight(.light)
                .size(12.0)
                .color(ColorLayout.accent.light))

            director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.updateAvailableTitle.localized,
                                                          layout: title))

            director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.updateAvailableMessage.localized,
                                                          layout: textLeftAligned))

            director?.elements.append(TableDirector.label(with: availableUpdate.compoundName,
                                                          layout: textCentered))

            director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.changelog.localized,
                                                          layout: textLeftAligned))

            director?.elements.append(TableDirector.label(with: availableUpdate.changelog,
                                                          layout: textLeftAligned))
        }
    }

    func configureAvailableFirmwareListViewModels() {

        guard let catalogService: CatalogService = Resolver.shared.resolve() else { return }

        let current = catalogService.catalog?.v2Firmware(with: self.param.node)

        guard let availableFirmwares = catalogService.catalog?.availableV2Firmwares(with: self.param.node.deviceId.longHex,
                                                                                    currentFirmware: current) else { return }

        if selectedFirmware == nil {
            selectedFirmware = availableFirmwares.first
        }

        let layout = Layout.standard
        let title = layout.text(textLayout: layout.textLayout?.weight(.bold))

        let textLeftAligned = layout.text(textLayout: layout.textLayout?.alignment(.left).size(12.0))

        director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.availableFirmwareList.localized,
                                                      layout: title))

        director?.elements.append(TableDirector.label(with: selectedFirmware?.compoundName,
                                                      key: FlashBankStatusPresenter.selectedFirmwareKey,
                                                      layout: layout,
                                                      image: ImageLayout.Common.arrowDown?.scalePreservingAspectRatio(targetSize: ImageSize.small),
                                                      tapHandler: { [weak self] param in
            guard let self = self else { return }

            var actions: [UIAlertAction] = availableFirmwares.map { firmware in
                UIAlertAction.genericButton(firmware.compoundName) { _ in

                    self.selectedFirmware = firmware
                    let installTitle = Localizer.Firmware.Text.installSelectedFirmware.localized + " \(firmware.compoundName)"

                    self.director?.updateVisibleCells(with: [
                        CodeValue<String>(keys: [ FlashBankStatusPresenter.selectedFirmwareKey ],
                                          value: firmware.compoundName),
                        CodeValue<String>(keys: [ FlashBankStatusPresenter.installFirmwareKey ],
                                          value: installTitle)
                    ])
                }
            }

            actions.append(UIAlertAction.cancelButton())

            UIAlertController.presentAlert(from: self.view,
                                           title: Localizer.Firmware.Text.selectFirmware.localized,
                                           style: .actionSheet,
                                           actions: actions)
        }))

        director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.selectedFirmwareDescriptionTitle.localized,
                                                      layout: textLeftAligned))

        director?.elements.append(TableDirector.label(with: selectedFirmware?.description,
                                                      layout: textLeftAligned))

        guard let selectedFirmware = selectedFirmware else { return }

        let installTitle = Localizer.Firmware.Text.installSelectedFirmware.localized + " \(selectedFirmware.compoundName)"

        director?.elements.append(TableDirector.button(with: installTitle,
                                                       key: FlashBankStatusPresenter.installFirmwareKey,
                                                       layout: Layout.standard.buttonLayout(buttonLayout: Buttonlayout.standardAccent),
                                                       tapHandler: { [weak self] _ in
            self?.installSelectedFirmware()
        }))

        director?.elements.append(TableDirector.button(with: Localizer.Firmware.Text.swapToThisBank.localized,
                                                       layout: Layout.standard.buttonLayout(buttonLayout: Buttonlayout.standardGray),
                                                       tapHandler: { [weak self] _ in
            self?.bankSwap()
        }))
    }

}
