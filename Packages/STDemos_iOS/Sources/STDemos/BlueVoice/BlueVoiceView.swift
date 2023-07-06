//
//  BlueVoiceView.swift
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
import CorePlot
import MediaPlayer

final class BlueVoiceView: UIView {
    
    @IBOutlet weak var beamFormingContainerView: UIStackView!

    @IBOutlet weak var codecDescrLabel: UILabel!
    @IBOutlet weak var codecLabel: UILabel!

    @IBOutlet weak var samplingDescLabel: UILabel!
    @IBOutlet weak var samplingLabel: UILabel!

    @IBOutlet weak var volumeDescLabel: UILabel!

    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var beamFormingDescLabel: UILabel!
    @IBOutlet weak var beamFormingSwitch: UISwitch!

    @IBOutlet weak var audioPlotContainerView: UIView!

    @IBOutlet weak var volumeView: MPVolumeView!

    var audioPlotView: CPTGraphHostingView = CPTGraphHostingView(frame: .zero)

    override func awakeFromNib() {
        super.awakeFromNib()

        let layout = TextLayout.text
            .alignment(.left)

        layout.apply(to: codecDescrLabel)
        layout.apply(to: codecLabel)

        layout.apply(to: samplingDescLabel)
        layout.apply(to: samplingLabel)

        layout.apply(to: volumeDescLabel)
        layout.apply(to: beamFormingDescLabel)

        codecLabel.text = nil
        codecDescrLabel.text = Localizer.BlueVoice.codec.localized

        samplingDescLabel.text = Localizer.BlueVoice.samplingFrequency.localized
        samplingLabel.text = nil

        volumeDescLabel.text = Localizer.BlueVoice.volume.localized
        beamFormingDescLabel.text = Localizer.BlueVoice.beamForming.localized

        audioPlotContainerView.addSubview(audioPlotView, constraints: UIView.fitToSuperViewConstraints)

        muteButton.setTitle(nil, for: .normal)

        muteButton.tintColor = ColorLayout.secondary.auto
        volumeView.tintColor = ColorLayout.secondary.auto

        Buttonlayout.imageLayout(image: UIImage(named: "img_volume_on", in: .module, compatibleWith: nil)?.template,
                                 selectedImage: UIImage(named: "img_volume_off", in: .module, compatibleWith: nil)?.template,
                                 color: ColorLayout.secondary.auto)
        .apply(to: muteButton)
    }
}
