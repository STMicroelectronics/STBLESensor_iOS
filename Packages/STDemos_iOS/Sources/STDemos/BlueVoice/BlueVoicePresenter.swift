//
//  BlueVoicePresenter.swift
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
import CorePlot
import STCore

final class BlueVoicePresenter: DemoPresenter<BlueVoiceViewController> {

    private var audioFeature: Feature?
    private var controlFeature: Feature?
    private var beamFormingFeature: Feature?

    private var audioPlayer: AudioPlayer?

    private var audioPlotDataSource: AudioPlotDataSource!

}

// MARK: - BlueVoiceDelegate
extension BlueVoicePresenter: BlueVoiceDelegate {

    func load() {

        demo = .blueVoice

        view.title = demo?.title
        
        view.configureView()

        demoFeatures.append(contentsOf: param.node.characteristics.features(with: Demo.blueVoice.features))

        audioFeature = bestAudioFeature()
        controlFeature = bestAudioFeature()
        beamFormingFeature = demoFeatures.first(where: { type(of: $0) == BeamFormingFeature.self })
    }

    func update(with feature: Feature, sample: AnyFeatureSample?) {
        if let audioFeature = feature as? AudioDataFeature,
           let sample = sample as? FeatureSample<ADPCMAudioData>,
           let data = sample.data?.audio,
           let audioPlayer = self.audioPlayer,
           feature.type.uuid == audioFeature.type.uuid {
            Logger.debug(text: feature.description(with: sample))

            audioPlayer.playSample(sample: data)

            self.updateAudioPlot(data)
        } else {
            if let audioFeature = self.audioFeature as? AudioDataFeature,
               let controlFeature = self.controlFeature,
               let sample = sample,
               feature.type.uuid == controlFeature.type.uuid {
                Logger.debug(text: feature.description(with: sample))

                audioFeature.codecManager.updateParameters(from: sample)
            }
        }
    }

    func startAudioPlayer() {
        audioPlotDataSource = AudioPlotDataSource(view: view.mainView.audioPlotView,
                                                  reDrawAfterSample: 3)
        enableBeamForming(true)

        guard let audioFeature = audioFeature as? AudioDataFeature,
              let _ = controlFeature else { return }

        self.audioPlayer = AudioPlayer(audioFeature.codecManager)

        view.mainView.codecLabel.text = audioFeature.codecManager.codecName
        view.mainView.samplingLabel.text = "\(audioFeature.codecManager.samplingFequency) kHz"
    }

    func mute(_ value: Bool) {
        audioPlayer?.mute = value
    }

    func enableBeamForming(_ value: Bool) {
        guard let beamFormingFeature = self.beamFormingFeature else {
            view.mainView.beamFormingContainerView.isHidden = true
            return
        }

        let command = BeamFormingCommand.enable(enabled: value)

        BlueManager.shared.sendCommand(FeatureCommand(type: command, data: command.payload),
                                       to: param.node,
                                       feature: beamFormingFeature)

        Logger.debug(text: command.description)

        let command2 = BeamFormingCommand.setDirection(direction: .right)

        BlueManager.shared.sendCommand(FeatureCommand(type: command2, data: command2.payload),
                                       to: param.node,
                                       feature: beamFormingFeature)

        Logger.debug(text: command2.description)

        let command3 = BeamFormingCommand.setBeamType(beamType: .strong)

        BlueManager.shared.sendCommand(FeatureCommand(type: command3, data: command3.payload),
                                       to: param.node,
                                       feature: beamFormingFeature)

        Logger.debug(text: command3.description)
    }

}

private extension BlueVoicePresenter {

    func bestAudioFeature() -> Feature? {

        if let feature = demoFeatures.first(where: { type(of: $0) == OpusAudioFeature.self }) {
            return feature
        }

        return demoFeatures.first(where: { type(of: $0) == ADPCMAudioFeature.self })
    }

    func bestAudioControlFeature() -> Feature? {

        if let feature = demoFeatures.first(where: { type(of: $0) == OpusAudioConfFeature.self }) {
            return feature
        }

        return demoFeatures.first(where: { type(of: $0) == ADPCMAudioSyncFeature.self })
    }

    func updateAudioPlot(_ sample: Data) {

        let value = sample.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> Int16? in
            return ptr.bindMemory(to: Int16.self).first
        }

        if let value = value {
            audioPlotDataSource.appendToPlot(value)
        }

    }
}
