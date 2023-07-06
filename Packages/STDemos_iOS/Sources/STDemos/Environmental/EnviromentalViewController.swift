//
//  EnviromentalViewController.swift
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

final class EnviromentalViewController: DemoNodeViewController<EnviromentalDelegate, EnviromentalView> {

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Enviromental_title"

        presenter.load()
    }

    override func configureView() {
        super.configureView()
    }

    func configureView(with features: [Feature]) {
        for feature in features {
            guard let sensorView = SensorView.make(with: STDemos.bundle) as? SensorView else { return }
            mainView.stackView.addArrangedSubview(sensorView)

            guard let feature = feature as? EnvironmentalFeature else { return }

            self.presenter.update(with: feature)
        }
    }

    override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        DispatchQueue.main.async { [weak self] in

//            guard let self = self else { return }
//            if type(of: self.feature) != type(of: feature) ||
//                feature.type.mask != self.feature.type.mask {
//                return
//            }
//
            guard let feature = feature as? EnvironmentalFeature else { return }

            self?.presenter.update(with: feature)

            Logger.debug(text: feature.description(with: sample))
//            self.textView.text = description
        }
    }

}
