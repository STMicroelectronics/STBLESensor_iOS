//
//  BatteryPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
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
import JGProgressHUD

final class BatteryPresenter: DemoPresenter<BatteryViewController> {

    private let batteryRangeImage: Int = 20

    var rssi: Int

    public init(rssi: Int, param: DemoParam<Void>) {
        self.rssi = rssi
        super.init(param: param)
    }

    override func prepareSettingsMenu() {

        super.prepareSettingsMenu()

        settingActions.append(SettingsAction(name: "Battery info",
                                                 handler: {
            BlueManager.shared.sendMessage("batteryinfo",
                                           to: self.param.node,
                                           completion: DebugConsoleCallback(timeOut: 1.0,
                                                                            onCommandResponds: { text in
                UIAlertController.presentAlert(from: self.view,
                                               title: Localizer.Common.warning.localized,
                                               message: text,
                                               actions: [ UIAlertAction.genericButton() ])
            }, onCommandError: {

            }))
        }))

        settingActions.append(view.cancelAction {

        })
    }

}

private extension BatteryPresenter {
    func getBatteryStatusImage(level: Float, status: BatteryStatus) -> UIImage? {

        let levelIndex = Int((level / Float(batteryRangeImage)) + 0.5) * batteryRangeImage

        if status != .charging {
            return ImageLayout.image(with: String(format: "battery_%d", levelIndex))
        } else {
            return ImageLayout.image(with: String(format: "battery_%dc", levelIndex))
        }
    }
}

// MARK: - BatteryDelegate
extension BatteryPresenter: BatteryDelegate {

    func load() {

        demo = .battery

        demoFeatures = param.node.characteristics.features(with: Demo.battery.features)

        view.configureView()
    }

    func updateValue(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<BatteryData> {

            if let value = sample.data?.level.value,
               let uom = sample.data?.level.uom {
                view.batteryView.chargeLabel.text = "\(value) \(uom)"
                view.batteryView.chargeImageView.image = getBatteryStatusImage(level: value,
                                                                               status: sample.data?.status ?? .unknown)
            }

            view.batteryView.statusLabel.text = sample.data?.status.description

            if let value = sample.data?.voltage.value,
               let uom = sample.data?.voltage.uom {
                view.batteryView.voltageLabel.text = "\(value) \(uom)"
            }
        }
    }

    func updateRSSI(with rssi: Int?) {
        view.rssiView.rssiLabel.text = "RSSI: \(rssi ?? 0)dBm"
    }
}

extension UIViewController {
    func startStopLoggingAction(stopHandler: @escaping () -> Void) -> SettingsAction {
        SettingsAction(name: BlueManager.shared.featureLogger.isEnabled ? "Stop logging" : "Start logging",
                       handler: {
            if BlueManager.shared.featureLogger.isEnabled {
                BlueManager.shared.featureLogger.stop()
                stopHandler()
            } else {
                BlueManager.shared.featureLogger.start()
            }
        })
    }

    func cancelAction(handler: @escaping () -> Void) -> SettingsAction {
        SettingsAction(name: Localizer.Common.cancel.localized,
                       style: .destructive,
                       handler: handler)
    }
}
