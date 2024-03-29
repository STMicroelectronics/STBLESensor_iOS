//
//  MachineLearningCoreViewController.swift
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

public final class MachineLearningCoreViewController: DemoNodeTableViewController<MachineLearningCoreDelegate, MachineLearningCoreView> {

    override public func makeView() -> MachineLearningCoreView {
        MachineLearningCoreView.make(with: STDemos.bundle) as? MachineLearningCoreView ?? MachineLearningCoreView()
    }
    
    override public func configure() {
        super.configure()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.machineLearningCore.title

        presenter.load()
        
        presenter.retrieveLabelData()
    }

    override public func configureView() {
        super.configureView()
    }
    
    override public func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        DispatchQueue.main.async { [weak self] in
            
            guard let feature = feature as? MachineLearningCoreFeature else { return }

            self?.presenter.updateMlcDemo(with: feature)

            Logger.debug(text: feature.description(with: sample))
        }
    }

}
