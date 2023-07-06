//
//  BaseNodeNoViewController.swift
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

open class BaseNodeNoViewController<Presenter>: BaseNoViewController<Presenter>, BlueDelegate {

    open override func configureView() {

    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        BlueManager.shared.addDelegate(self)
        hideTabBar()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        BlueManager.shared.removeDelegate(self)
    }

    open func deinitController() {

    }

    deinit {
        BlueManager.shared.removeDelegate(self)
        Logger.debug(text: "DEINIT: \(String(describing: self))")
        deinitController()

    }

    open func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {

    }

    open func manager(_ manager: BlueManager, didDiscover node: Node) {

    }

    open func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {

    }

    open func manager(_ manager: BlueManager, didChangeStateFor node: Node) {

    }

    open func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {

    }

    open func manager(_ manager: BlueManager, didReceiveCommandResponseFor
                 node: Node,
                 feature: Feature,
                 response: FeatureCommandResponse) {
        Logger.debug(text: "\(response.description)")
    }
}

