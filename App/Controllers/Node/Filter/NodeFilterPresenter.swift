//
//  NodeFilterPresenter.swift
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

typealias RSSIChangeHandler = (_ minRssi: Int) -> Void

final class NodeFilterPresenter: VoidPresenter<NodeFilterViewController> {

    var rssiChangeHandler: RSSIChangeHandler?
    var currentRssiValue: Int = 0

    convenience init(with currentRssiValue: Int,
                     rssiChangeHandler: @escaping RSSIChangeHandler) {
        self.init()
        self.currentRssiValue = currentRssiValue
        self.rssiChangeHandler = rssiChangeHandler
    }

}

// MARK: - NodeFilterViewControllerDelegate
extension NodeFilterPresenter: NodeFilterDelegate {

    func load() {
        view.configureView()

        view.sliderView.minimumValue = 4
        view.sliderView.maximumValue = 100
        view.sliderView.value = -Float(currentRssiValue)
        view.currentValueLabel.text = "\(currentRssiValue) dBm"

        view.sliderView.on(.valueChanged) { [weak self] slider in
            guard let rssiChangeHandler = self?.rssiChangeHandler else { return }
            let value = -Int(slider.value)
            self?.view.currentValueLabel.text = "\(value) dBm"
            rssiChangeHandler(value)
        }
    }

    func dismisss() {
        self.view.dismiss(animated: true)
    }

}
