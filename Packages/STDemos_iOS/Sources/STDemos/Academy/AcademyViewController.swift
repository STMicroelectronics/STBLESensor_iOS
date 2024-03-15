//
//  AcademyViewController.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class AcademyViewController: DemoNodeNoViewController<AcademyDelegate> {
    
    override func configure() {
        super.configure()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Academy Demo"

        presenter.load()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func manager(
        _ manager: BlueManager,
        didUpdateValueFor node: Node,
        feature: Feature,
        sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
    }
}
