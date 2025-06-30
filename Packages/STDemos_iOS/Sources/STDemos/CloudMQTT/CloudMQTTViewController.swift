//
//  CloudMQTTViewController.swift
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

final class CloudMQTTViewController: DemoNodeNoViewController<CloudMQTTDelegate> {
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        title = Demo.cloudMqtt.title
        title = ""

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
//        if let presenter = presenter as? CloudMQTTPresenter {
//            let node = presenter.param.node
//            presentSwiftUIView(CloudMQTTAppConfigView(node: node))
//        }
//        
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        
        DispatchQueue.main.async { [weak self] in
            print(sample)
        }
    }

    
}
