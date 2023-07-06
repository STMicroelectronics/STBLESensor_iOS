//
//  AudioSourceLocalizationViewController.swift
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

final class AudioSourceLocalizationViewController: DemoNodeViewController<AudioSourceLocalizationDelegate, AudioSourceLocalizationView> {

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.audioSourceLocalization.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        mainView.sensitivitySwitch.isOn = true
        mainView.sensitivitySwitch.addTarget(self, action: #selector(sensitivitySwitchTapped), for: .valueChanged)
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateAudioSourceLocalizationUI(with: sample)
        }
    }
    
}

extension AudioSourceLocalizationViewController {
    @objc
    func sensitivitySwitchTapped(_ sender: UISwitch) {
        presenter.setSensitivity()
    }
}
