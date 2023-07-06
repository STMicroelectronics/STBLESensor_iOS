//
//  FirmwareCheckerViewController.swift
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

public final class FirmwareCheckerViewController: TableViewController<FirmwareCheckerDelegate, FirmwareCheckerView>, BlueDelegate {

    override public func makeView() -> FirmwareCheckerView {
        FirmwareCheckerView.make(with: STDemos.bundle) as? FirmwareCheckerView ?? FirmwareCheckerView()
    }

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.Firmware.Text.title.localized

        presenter.load()
    }

    public override func configureView() {
        super.configureView()
    }

    public func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {

    }

    public func manager(_ manager: STBlueSDK.BlueManager, didDiscover node: STBlueSDK.Node) {

    }

    public func manager(_ manager: STBlueSDK.BlueManager, didRemoveDiscovered nodes: [STBlueSDK.Node]) {

    }

    public func manager(_ manager: STBlueSDK.BlueManager, didChangeStateFor node: STBlueSDK.Node) {

    }

    public func manager(_ manager: STBlueSDK.BlueManager, didUpdateValueFor node: STBlueSDK.Node, feature: STBlueSDK.Feature, sample: STBlueSDK.AnyFeatureSample?) {

    }

    public func manager(_ manager: STBlueSDK.BlueManager, didReceiveCommandResponseFor node: STBlueSDK.Node, feature: STBlueSDK.Feature, response: STBlueSDK.FeatureCommandResponse) {
        
    }
}
