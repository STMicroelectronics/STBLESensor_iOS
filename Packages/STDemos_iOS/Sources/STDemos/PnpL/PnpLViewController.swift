//
//  PnpLViewController.swift
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

final public class PnpLViewController: DemoNodeTableViewController<PnpLDelegate, PnpLView> {

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "PnpL_title"

        self.removeDelegateWhenDisappear = false
        presenter.load()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        self.presenter.disableNotificationOnDisappear = false
        super.viewWillDisappear(animated)
    }

    public override func configureView() {
        super.configureView()
    }

    public override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        DispatchQueue.main.async { [weak self] in

//            guard let self = self else { return }
//            if type(of: self.feature) != type(of: feature) ||
//                feature.type.mask != self.feature.type.mask {
//                return
//            }
//
            guard let feature = feature as? PnPLFeature else { return }

            Logger.debug(text: feature.description(with: sample))

            self?.presenter.update(with: feature)
        }
    }

}
