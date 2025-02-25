//
//  PianoPresenter.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//


import STBlueSDK
import STCore

final class PianoPresenter: DemoPresenter<PianoViewController> {
   
}

extension PianoPresenter: PianoDelegate {
    
    func load() {
        demo = .piano
        
        demoFeatures = param.node.characteristics.features(with: Demo.piano.features)
        
        view.configureView()
    }
    
    
    func  playPianoSound(key: Int8) {
        sendPianoCommand(PianoCommand.start(key: key))
    }
    
    func stopPianoSound() {
        sendPianoCommand(PianoCommand.stop)
    }
    
}

extension PianoPresenter {
    private func sendPianoCommand(_ command: PianoCommand) {
        if let pianoFeature = param.node.characteristics.first(with: PianoFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: pianoFeature
            )
            
            Logger.debug(text: command.description)
        }
    }
}
