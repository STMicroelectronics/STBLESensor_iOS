//
//  RawPnPLControlledViewController.swift
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

final class RawPnPLControlledViewController: DemoNodeNoViewController<RawPnPLControlledDelegate> {
    
    override func configure() {
        super.configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.requestStatusUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Raw PnPL Controlled"

        presenter.load()
    }

    override func configureView() {
        super.configureView()
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        
        DispatchQueue.main.async { [weak self] in
            if feature is PnPLFeature {
                self?.presenter.newPnPLSample(with: sample, and: feature)
            } else if feature is RawPnPLControlledFeature {
                self?.presenter.newRawPnPLControlledSample(with: sample, and: feature)
            }
        }
    }

}
