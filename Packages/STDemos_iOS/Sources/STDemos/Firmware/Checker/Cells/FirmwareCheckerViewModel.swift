//
//  FirmwareCheckerViewModel.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STUI
import STBlueSDK

public struct Firmwares {
    public let current: Firmware
    public let availables: [Firmware]
    public let isMandatory: Bool

    public init(current: Firmware, availables: [Firmware], isMandatory: Bool = false) {
        self.current = current
        self.availables = availables
        self.isMandatory = isMandatory
    }
}

public enum FirmwareCheckerAction {
    case cancel(dontAskAgain: Bool)
    case install(firmware: Firmware, dontAskAgain: Bool)
}

public class FirmwareCheckerViewModel: BaseCellViewModel<Firmwares, FirmwareCheckerCell> {

    let completion: (FirmwareCheckerAction) -> Void

    public init(param: Firmwares, completion: @escaping (FirmwareCheckerAction) -> Void) {
        self.completion = completion
        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }
    
    public override func configure(view: FirmwareCheckerCell) {

        TextLayout.title2.apply(to: view.currentFirmwareDescLabel)
        TextLayout.title2.apply(to: view.updateFirmwareDescLabel)
        TextLayout.title2.apply(to: view.changeLogDescLabel)

        TextLayout.info.apply(to: view.currentFirmwareLabel)
        TextLayout.info.color(ColorLayout.accent.light).apply(to: view.updateFirmwareLabel)
        TextLayout.info.apply(to: view.changeLogLabel)

        view.currentFirmwareLabel.text = param?.current.fullName
        view.updateFirmwareLabel.text = param?.availables.first?.fullName
        view.changeLogLabel.text = param?.availables.first?.changelog

        Buttonlayout.standard.apply(to: view.installButton, text: "INSTALL")
        Buttonlayout.standardGray.apply(to: view.cancelButton, text: "CANCEL")
        
        Buttonlayout.imageLayout(image: ImageLayout.Common.squareUnchecked?
            .scalePreservingAspectRatio(targetSize: ImageSize.small)
            .maskWithColor(color: ColorLayout.primary.light),
                                 selectedImage: ImageLayout.Common.squareChecked?
            .scalePreservingAspectRatio(targetSize: ImageSize.small)
            .maskWithColor(color: ColorLayout.primary.light),
                                 color: ColorLayout.primary.light).apply(to: view.dontAskAgainButton)


        view.updateFirmwareDescLabel.text = param?.isMandatory ?? false ? "Suggested firmware" : "Update Available"

        view.dontAskAgainButton.isHidden = param?.isMandatory ?? false
        view.dontAskAgainDescLabel.isHidden = param?.isMandatory ?? false

        view.infoInstallLabel.text = param?.isMandatory ?? false ? "PLEASE NOTE: the current firmware is not supported. You need to install the suggested firmware in order to use the app": "PLEASE NOTE: Firmware update always available under Board Configuration → Firmware Download"

        view.dontAskAgainButton.onTap { _ in
            view.dontAskAgainButton.isSelected = !view.dontAskAgainButton.isSelected
        }

        view.cancelButton.onTap { [weak self] sender in
            guard let self else { return }
            self.completion(.cancel(dontAskAgain: view.dontAskAgainButton.isSelected))
        }

        view.installButton.onTap { [weak self] sender in
            guard let self,
                    let firmware = self.param?.availables.first else { return }
            self.completion(.install(firmware: firmware, dontAskAgain: view.dontAskAgainButton.isSelected))
        }
    }

}
