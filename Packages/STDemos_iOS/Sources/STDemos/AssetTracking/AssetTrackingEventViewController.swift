//
//  AssetTrackingEventViewController.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK

final class AssetTrackingEventViewController: DemoNodeNoViewController<AssetTrackingEventDelegate> {
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.assetTrackingEvent.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
    }
}
