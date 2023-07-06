//
//  ExtendedConfigurationViewController.swift
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
import STCore
import STBlueSDK

final class ExtendedConfigurationViewController: DemoNodeTableViewController<ExtendedConfigurationDelegate, ExtendedConfigurationView> {

    override public func makeView() -> ExtendedConfigurationView {
        ExtendedConfigurationView.make(with: STDemos.bundle) as? ExtendedConfigurationView ?? ExtendedConfigurationView()
    }

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "ExtendedConfiguration_title"

        presenter.load()
    }

    override func configureView() {
        super.configureView()
    }

    override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {

        guard let sample = sample as? FeatureSample<ExtendedConfigurationData>,
              let response = sample.data?.response.value else { return }

        Logger.debug(text: "\(sample.description)")

        presenter.manageResponse(response: response)
    }

    override func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        Logger.debug(text: "\(response.description)")
    }

}
