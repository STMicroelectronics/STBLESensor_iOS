//
//  BlueVoiceViewController.swift
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

final class BlueVoiceViewController: DemoNodeViewController<BlueVoiceDelegate, BlueVoiceView> {

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.blueVoice.title

        presenter.load()

        mainView.beamFormingSwitch.addTarget(self, action: #selector(beamFormingSwitchValueChanged(_:)), for: .valueChanged)
        mainView.muteButton.addTarget(self, action: #selector(muteButtonTouched(_:)), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter.startAudioPlayer()
    }

    override func configureView() {
        super.configureView()
    }

    override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {

        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }

            self.presenter.update(with: feature, sample: sample)
        }
    }

    @objc
    func beamFormingSwitchValueChanged(_ sender: UISwitch?) {

    }

    @objc
    func muteButtonTouched(_ sender: UIButton?) {
        guard let sender = sender else { return }
        sender.isSelected = !sender.isSelected
        presenter.mute(sender.isSelected)
    }
}
