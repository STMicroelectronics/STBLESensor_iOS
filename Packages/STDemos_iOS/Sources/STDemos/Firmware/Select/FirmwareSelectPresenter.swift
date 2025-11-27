//
//  FirmwareSelectPresenter.swift
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

struct FirmwareSelect {
    let firmware: Firmware
    let isMandatory: Bool
    public let completion: ((Bool) -> ())?

    init(firmware: Firmware, isMandatory: Bool = false, completion: ((Bool) -> ())? = nil) {
        self.firmware = firmware
        self.isMandatory = isMandatory
        self.completion = completion
    }
}

final class FirmwareSelectPresenter: DemoBasePresenter<FirmwareSelectViewController, FirmwareSelect> {
    var customUrl: URL?
}

extension FirmwareSelectPresenter: FirmwareSelectDelegate {
    func load() {

        view.firmwareSelectType = BlueManager.shared.firmwareServiceType(for: param.node)

        if let catalogService: CatalogService = Resolver.shared.resolve() {
            BlueManager.shared.firmwareCurrentVersion(for: param.node, catalog: catalogService.catalog) { [weak self] version in
                Logger.debug(text: version.debugDescription)

                self?.view.boardInfoView.nameLabel.text = version?.name
                self?.view.boardInfoView.versionLabel.text = version?.stringValue
                self?.view.boardInfoView.mcuTypeLabel.text = version?.mcuType
            }
        }


        if view.firmwareSelectType == .stm32 {
            if let typeView = STM32FirmwareTypeView.make(with: STDemos.bundle) as? STM32FirmwareTypeView {
                let type: WbBoardType = if param.node.type == .nucleoWB0X {
                    .wb09
                } else if (param.node.type == .wba65RiNucleoBoard) || (param.node.type == .stm32wba65iDk1Board) {
                    .wba6
                } else if (param.node.type == .st67w6x) {
                    .st67w6x
                } else if (param.node.type == .wba2NucleoBoard) {
                    .wba2
                }  else if param.node.type.family == .wbaFamily {
                    .wba5
                } else {
                    .wb55
                }
                
                //typeView.configure(with: .application(board: (param.node.type == .wbaBoard) ? .wba5 : .wb55))
                typeView.configure(with: .application(board:type))
                typeView.translatesAutoresizingMaskIntoConstraints = false

                view.stackView.addArrangedSubview(typeView)
                typeView.heightAnchor.constraint(equalToConstant: 320.0).isActive = true
                view.typeView = typeView
            }
//        } else if view.firmwareSelectType == .blueNrg {
//            view.firmwareType = .custom(startSector: nil, numberOfSectors: 0, sectorSize: 0)
        }

        let firmwareLabel = UILabel()
        TextLayout.info.apply(to: firmwareLabel)

        firmwareLabel.text = param.param?.firmware.compoundName ?? Localizer.Firmware.Action.select.localized

        let firmwareSelectButton = UIButton(frame: .zero)
        firmwareSelectButton.isHidden = param.param?.isMandatory ?? false
        let image = ImageLayout.Common.folder?
            .scalePreservingAspectRatio(targetSize: ImageSize.small)
            .maskWithColor(color: ColorLayout.secondary.light)
        firmwareSelectButton.setImage(image, for: .normal)
        firmwareSelectButton.on(.touchUpInside) { _ in

            FilePicker.shared.pickFile(with: [ .bin ]) { [weak self] url in

                guard let self = self,
                let url = url else { return }

                self.customUrl = url
                firmwareLabel.text = url.lastPathComponent

            }
        }

        firmwareSelectButton.translatesAutoresizingMaskIntoConstraints = false
        firmwareSelectButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        firmwareSelectButton.widthAnchor.constraint(equalToConstant: 40).isActive = true

        view.stackView.addArrangedSubview(firmwareSelectButton)

        let upgradeButton = UIButton(frame: .zero)
        
        Buttonlayout.standard.apply(to: upgradeButton, text: Localizer.Firmware.Action.upgrade.localized)

        upgradeButton.on(.touchUpInside) { [weak self] _ in
            guard let self = self else { return }

            if let typeView = self.view.typeView,
               let firmwareType = typeView.firmwareType {
                if let url = self.customUrl {
                    self.installFirmware(at: url, type: firmwareType)
                } else {
                    self.firmwareUpgrade(with: firmwareType)
                }
            } else {
                if let url = self.customUrl {
                    self.installFirmware(at: url, type: self.view.firmwareType)
                } else {
                    self.firmwareUpgrade(with: self.view.firmwareType)
                }
            }
        }

        upgradeButton.translatesAutoresizingMaskIntoConstraints = false
        upgradeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let stackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                           views: [
                                                            firmwareLabel,
                                                            firmwareSelectButton
                                                           ])

        view.stackView.addArrangedSubview(stackView.embedInView(with: UIEdgeInsets.standard))
        view.stackView.addArrangedSubview(upgradeButton.embedInView(with: UIEdgeInsets.standard.top(20.0)))

        view.stackView.addArrangedSubview(UIView())
        
    }
}

private extension FirmwareSelectPresenter {
    func firmwareUpgrade(with type: FirmwareType) {

        guard let firmware = param.param?.firmware else { return }

        URLSession.shared.directDownloadFirmware(firmware) { [weak self] result in

            switch result {
            case .success(let url):
                Logger.debug(text: url.absoluteString)
                self?.installFirmware(at: url, type: type)
            case .failure(let error):

                guard let view = self?.view else { return }

                DispatchQueue.main.async {
                    UIAlertController.presentAlert(from: view,
                                                   title: Localizer.Common.warning.localized,
                                                   message: "Corrupted file",
                                                   actions: [ UIAlertAction.genericButton() ])

                    Logger.debug(text: error.localizedDescription)
                }
            }
        }

    }

    func installFirmware(at url: URL, type: FirmwareType) {
        if let catalogService: CatalogService = Resolver.shared.resolve(),
            let catalog = catalogService.catalog {

            self.view.hud.progress = 0.0
            self.view.hud.show(in: self.view.view)

            self.view.navigationController?.navigationBar.isUserInteractionEnabled = false

            BlueManager.shared.firmwareUpgrade(for: self.param.node,
                                               type: type,
                                               url: url,
                                               catalog: catalog,
                                               callback: DefaultFirmwareUpgradeCallback(completion: { [weak self] url, error in

                guard let self = self else { return }

                DispatchQueue.main.async {

                    self.view.navigationController?.navigationBar.isUserInteractionEnabled = true

                    self.view.hud.dismiss(afterDelay: 0.5, animated: true) { [weak self] in

                        guard let self else { return }

                        self.view.hud.indicatorView = nil
                        self.view.hud.textLabel.text = "Firmware upgrade success"
                        self.view.hud.detailTextLabel.text = nil
                        self.view.hud.show(in: self.view.view)
                        self.view.hud.dismiss(afterDelay: 2.0, animated: true) { [weak self] in

                            if let completion = self?.param.param?.completion {
                                completion(true)
                            }

                            if let error = error {
                                Logger.debug(text: "[Firmware upgrade] Fail with error: \(error.localizedDescription)")
                                if self?.view.presentingViewController != nil {
                                    self?.view.dismiss(animated: true)
                                    if let node = self?.param.node {
                                        BlueManager.shared.disconnect(node)
                                    }
                                } else {
                                    self?.view.navigationController?.popToRootViewController(animated: true)
                                }
                                return
                            }

                            Logger.debug(text: "[Firmware upgrade] Complete with success")
                            if self?.view.presentingViewController != nil {
                                self?.view.dismiss(animated: true)
                                if let node = self?.param.node {
                                    BlueManager.shared.disconnect(node)
                                }
                            } else {
                                self?.view.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }

            }, progress: { [weak self] url, bytes, totalBytes in

                guard let self = self else { return }

                Logger.debug(text: "[Firmware upgrade] Remaining bytes: \(bytes)/\(totalBytes)")

                let percentage = Float(bytes) / Float(totalBytes)

                DispatchQueue.main.async {
                    self.view.hud.progress = percentage
                    self.view.hud.detailTextLabel.text = String(format: "%.2f%% Complete", percentage * 100.0)
                }
            }))
        }

    }
}
