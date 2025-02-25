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
        director?.register(viewModel: ContainerCellViewModel
                           <any ViewViewModel>.self,
                           type: .fromClass,
                           bundle: STUI.bundle)
        director?.register(viewModel: DivisorViewModel.self,
                           type: .fromClass,
                           bundle: STDemos.bundle)
        
        /// CURRENT BANK
        let bankStatusViewModel = LabelViewModel(param: CodeValue<String>(value: Localizer.Firmware.Text.bankStatus.localized(with: [ param.bankStatus.currentBank ])),
                                                 layout: Layout.title2)
        director?.elements.append(ContainerCellViewModel(childViewModel: bankStatusViewModel, layout: Layout.title2))
        
        let currentFwLabelViewModel = LabelViewModel(param: CodeValue<String>(value: Localizer.Firmware.Text.currentRunningFirmware.localized),
                                                     layout: Layout.info)
        director?.elements.append(ContainerCellViewModel(childViewModel: currentFwLabelViewModel, layout: Layout.info))
        
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let firmwareName = catalogService.catalog?.v2Firmware(with: param.node)?.compoundName {
            let fwNameLabelViewModel = LabelViewModel(param: CodeValue<String>(value: firmwareName),
                                                      layout: Layout.standardCenterSecondary)
            director?.elements.append(ContainerCellViewModel(childViewModel: fwNameLabelViewModel, layout: Layout.standardCenterSecondary))
        } else {
            let fwNameLabelViewModel = LabelViewModel(param: CodeValue<String>(value: Localizer.Firmware.Text.firmwareUnknown.localized),
                                                      layout: Layout.standardCenterSecondary)
            director?.elements.append(ContainerCellViewModel(childViewModel: fwNameLabelViewModel, layout: Layout.standardCenterSecondary))
        }
        
        /// DIVISOR
        director?.elements.insert(DivisorViewModel(), at: director?.elements.count ?? 0)
        
        /// OTHER BANK
        let otherBankStatusViewModel = LabelViewModel(param: CodeValue<String>(value: Localizer.Firmware.Text.otherBankStatus.localized),
                                                      layout: Layout.title2)
        director?.elements.append(ContainerCellViewModel(childViewModel: otherBankStatusViewModel, layout: Layout.title2))
        
        
        let otherFwLabelViewModel = LabelViewModel(param: CodeValue<String>(value: Localizer.Firmware.Text.firmwarePresent.localized),
                                                   layout: Layout.info)
        director?.elements.append(ContainerCellViewModel(childViewModel: otherFwLabelViewModel, layout: Layout.info))
        
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let firmwareName = catalogService.catalog?.v2Firmware(with: param.node.deviceId.longHex,
                                                                 firmwareId: param.bankStatus.fwId2.lowercased(),
                                                                 checkCustomFirmware: false)?.compoundName {
            let fwNameLabelViewModel = LabelViewModel(param: CodeValue<String>(value: firmwareName),
                                                      layout: Layout.standardCenterSecondary)
            director?.elements.append(ContainerCellViewModel(childViewModel: fwNameLabelViewModel, layout: Layout.standardCenterSecondary))
            
            director?.elements.append(TableDirector.button(with: Localizer.Firmware.Text.swapToThisBank.localized,
                                                           layout: Layout.standard.buttonLayout(buttonLayout: Buttonlayout.standard),
                                                           tapHandler: { [weak self] _ in
                self?.bankSwap()
            }))
        } else {
            let fwNameLabelViewModel = LabelViewModel(param: CodeValue<String>(value: Localizer.Firmware.Text.firmwareUnknown.localized),
                                                      layout: Layout.standardCenterSecondary)
            director?.elements.append(ContainerCellViewModel(childViewModel: fwNameLabelViewModel, layout: Layout.standardCenterSecondary))
        }
        
        /// DIVISOR
        director?.elements.insert(DivisorViewModel(), at: director?.elements.count ?? 0)
        
        /// COMPATIBLE FIRMWARES
        let compatileFwLabelViewModel = LabelViewModel(param: CodeValue<String>(value: "Compatible Firmwares"),
                                                       layout: Layout.title2)
        director?.elements.append(ContainerCellViewModel(childViewModel: compatileFwLabelViewModel, layout: Layout.title2))
    }
    
    //    func configureAvailableUpdateViewmodels() {
    //        if let catalogService: CatalogService = Resolver.shared.resolve(),
    //           let current = catalogService.catalog?.v2Firmware(with: param.node),
    //           let availableUpdate = catalogService.catalog?.mostRecentAvailableNewV2Firmware(with: param.node.deviceId.longHex,
    //                                                                                              currentFirmware: current) {
    //
    //            selectedFirmware = availableUpdate
    //
    //            let layout = Layout.standard
    //            let title = layout.text(textLayout: layout.textLayout?.weight(.bold))
    //
    //            let textLeftAligned = layout.text(textLayout: layout.textLayout?.alignment(.left).size(12.0))
    //            let textCentered = layout.text(textLayout: layout.textLayout?
    //                .alignment(.center)
    //                .weight(.light)
    //                .size(12.0)
    //                .color(ColorLayout.accent.auto))
    //
    //            director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.updateAvailableTitle.localized,
    //                                                          layout: title))
    //
    //            director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.updateAvailableMessage.localized,
    //                                                          layout: textLeftAligned))
    //
    //            director?.elements.append(TableDirector.label(with: availableUpdate.compoundName,
    //                                                          layout: textCentered))
    //
    //            director?.elements.append(TableDirector.label(with: Localizer.Firmware.Text.changelog.localized,
    //                                                          layout: textLeftAligned))
    //
    //            director?.elements.append(TableDirector.label(with: availableUpdate.changelog,
    //                                                          layout: textLeftAligned))
    //        }
    //    }
    
    func configureAvailableFirmwareListViewModels() {
        
        guard let catalogService: CatalogService = Resolver.shared.resolve() else { return }
        
        guard let current = catalogService.catalog?.v2Firmware(with: self.param.node) else { return }
        
        guard let availableFirmwaresBackup = catalogService.catalog?.availableV2Firmwares(with: self.param.node.deviceId.longHex,
                                                                                          currentFirmware: current,
                                                                                          enabledFirmwares: nil) else { return }
        
        var availableFirmwares = availableFirmwaresBackup
        
        if selectedFirmware == nil {
            selectedFirmware = availableFirmwares.first
        }
        
        let showLatestModel = SwitchViewModel(param: CodeValue<SwitchInput>(value: SwitchInput(title: "Show only latest",
                                                                                               value: false,
                                                                                               isEnabled: true,
                                                                                               handleValueChanged: { [weak self] value in
            guard let self else { return }
            
            
            if value.value.value == true {
                //we take only the latest... and we skip any eventually entry with the same name of the current one, but with a lower version number
                availableFirmwares = availableFirmwaresBackup.uniqueFwName.filter{ item in !(item.name == current.name && item.version < current.version) }
            } else {
                availableFirmwares = availableFirmwaresBackup
            }
            if let firmware = availableFirmwares.first {
                self.selectedFirmware = firmware
                
                
                let installTitle = Localizer.Firmware.Text.installSelectedFirmware.localized + " \(firmware.compoundName)"
                
                self.director?.updateVisibleCells(with: [
                    CodeValue<String>(keys: [ FlashBankStatusPresenter.selectedFirmwareKey ],
                                      value: self.selectedFirmware?.compoundName ?? ""),
                    CodeValue<String>(keys: [ FlashBankStatusPresenter.installFirmwareKey ],
                                      value: installTitle),
                    CodeValue<String>(keys: [ FlashBankStatusPresenter.descriptionFirmwareKey],
                                      value: self.selectedFirmware?.description ?? "")
                ])
            }
            
        })),layout: Layout.info)
        
        director?.elements.append(ContainerCellViewModel(childViewModel: showLatestModel, layout: Layout.info))
        
        let selectedFwViewModel = LabelViewModel(
            param: CodeValue<String>(
                keys: [FlashBankStatusPresenter.selectedFirmwareKey],
                value: selectedFirmware?.compoundName ?? ""),
            layout: Layout.standard,
            image: ImageLayout.Common.arrowDown?.scalePreservingAspectRatio(targetSize: ImageSize.small).maskWithColor(color: ColorLayout.primary.auto),
            handleTap: { [weak self] param in
                guard let self = self else { return }
                
                var actions: [UIAlertAction] = availableFirmwares.map { firmware in
                    UIAlertAction.genericButton(firmware.compoundName) { _ in
                        
                        self.selectedFirmware = firmware
                        let installTitle = Localizer.Firmware.Text.installSelectedFirmware.localized + " \(firmware.compoundName)"
                        
                        self.director?.updateVisibleCells(with: [
                            CodeValue<String>(keys: [ FlashBankStatusPresenter.selectedFirmwareKey ],
                                              value: self.selectedFirmware?.compoundName ?? ""),
                            CodeValue<String>(keys: [ FlashBankStatusPresenter.installFirmwareKey ],
                                              value: installTitle),
                            CodeValue<String>(keys: [ FlashBankStatusPresenter.descriptionFirmwareKey],
                                              value: self.selectedFirmware?.description ?? "")
                        ])
                    }
                }
                
                actions.append(UIAlertAction.cancelButton())
                
                UIAlertController.presentAlert(from: self.view,
                                               title: Localizer.Firmware.Text.selectFirmware.localized,
                                               style: .actionSheet,
                                               actions: actions)
            }
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: selectedFwViewModel, layout: Layout.standard))
        
        let descriptionLabelFwLabelViewModel = LabelViewModel(param: CodeValue<String>(value: Localizer.Firmware.Text.selectedFirmwareDescriptionTitle.localized),
                                                              layout: Layout.infoBold)
        director?.elements.append(ContainerCellViewModel(childViewModel: descriptionLabelFwLabelViewModel, layout: Layout.infoBold))
        
        let descriptionFwViewModel = LabelViewModel(
            param: CodeValue<String>(
                keys: [FlashBankStatusPresenter.descriptionFirmwareKey],
                value: selectedFirmware?.description ?? ""),
            layout: Layout.info
        )
        
        director?.elements.append(ContainerCellViewModel(childViewModel: descriptionFwViewModel, layout: Layout.info))
        
        guard let selectedFirmware = selectedFirmware else { return }
        
        let installTitle = Localizer.Firmware.Text.installSelectedFirmware.localized + "\n\(selectedFirmware.compoundName)"
        
        let installButtonFwViewModel = ButtonViewModel(
            param: CodeValue<ButtonInput>(
                keys: [ FlashBankStatusPresenter.installFirmwareKey ],
                value: ButtonInput(title: installTitle)
            ),
            layout: Layout.standard.buttonLayout(buttonLayout: Buttonlayout.standard),
            handleButtonTouched: { [weak self] _ in
                self?.installSelectedFirmware()
            }
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: installButtonFwViewModel, layout: Layout.standard))
    }
    
}
