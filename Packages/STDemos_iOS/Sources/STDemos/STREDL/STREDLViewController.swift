//
//  STREDLViewController.swift
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

final class STREDLViewController: DemoNodeTableViewController<STREDLDelegate, STREDLView> {

    override public func makeView() -> STREDLView {
        STREDLView.make(with: STDemos.bundle) as? STREDLView ?? STREDLView()
    }
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.stredl.title

        presenter.load()
        
        presenter.retrieveLabelData()
    }

    override func configureView() {
        super.configureView()
    }
    
    override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        DispatchQueue.main.async { [weak self] in
            
            guard let feature = feature as? STREDLFeature else { return }

            self?.presenter.update(with: feature)

            Logger.debug(text: feature.description(with: sample))
        }
    }


}
