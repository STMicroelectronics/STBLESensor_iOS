//
//  FlashBankStatusViewController.swift
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

final class FlashBankStatusViewController: TableViewController<FlashBankStatusDelegate, FlashBankStatusView> {

    override public func makeView() -> FlashBankStatusView {
        FlashBankStatusView.make(with: STDemos.bundle) as? FlashBankStatusView ?? FlashBankStatusView()
    }

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.Firmware.Text.title.localized

        let closeButton = UIBarButtonItem(image: ImageLayout.Common.chevronDown,
                                          style: .plain,
                                          closure: { [weak self] _ in
            self?.dismiss(animated: true)
        })

        navigationItem.rightBarButtonItems = [ closeButton ]

        presenter.load()
    }

    override func configureView() {
        super.configureView()
    }

}
