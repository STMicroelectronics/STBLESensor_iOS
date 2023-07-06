//
//  BeamFormingPresenter.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import STUI
import STBlueSDK
import STCore

final class BeamFormingPresenter: DemoPresenter<BeamFormingViewController> {
    
    private var audioFeature: Feature?
    private var controlFeature: Feature?
    private var beamFormingFeature: Feature?
    
    private var audioPlayer: AudioPlayer?
    
    private var audioPlotDataSource: AudioPlotDataSource!
}

// MARK: - BeamFormingViewControllerDelegate
extension BeamFormingPresenter: BeamFormingDelegate {

    func load() {
        
        demo = .beamforming
        
        demoFeatures = param.node.characteristics.features(with: Demo.beamforming.features)
        
        view.configureView()
        
        audioFeature = bestAudioFeature()
        controlFeature = bestAudioFeature()
        beamFormingFeature = demoFeatures.first(where: { type(of: $0) == BeamFormingFeature.self })
        
        view.mainView.mBoardImage.image = getBoardSchemaImage(baseOnNodeType: param.node.type)
        
        if(param.node.type == .nucleo) {
            view.mainView.mBoardImage.setDimensionContraints(width: 100, height: 100)
            displayNucleoDemoSetup()
        }
    }
    
    func updateBeamformingUI(with feature: Feature, with sample: AnyFeatureSample?) {
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

    func changeDirection(_ direction: BeamFormingDirection) {
        guard let beamFormingFeature = self.beamFormingFeature else {
            return
        }
        
        let directionCommand = BeamFormingCommand.setDirection(direction: direction)

        BlueManager.shared.sendCommand(
            FeatureCommand(
                type: directionCommand,
                data: directionCommand.payload
            ),
            to: param.node,
            feature: beamFormingFeature
        )

    }
    
    func startAudioPlayer() {
        audioPlotDataSource = AudioPlotDataSource(view: view.mainView.mGraphView,
                                                  reDrawAfterSample: 3)
        
        enableBeamForming(true)
        
        guard let audioFeature = audioFeature as? AudioDataFeature,
              let _ = controlFeature else { return }
        
        self.audioPlayer = AudioPlayer(audioFeature.codecManager)
        
        self.view.mainView.mRightButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_on", in: .module), for: .normal)
    }

    func enableBeamForming(_ value: Bool) {
        guard let beamFormingFeature = self.beamFormingFeature else {
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
    
    private func displayNucleoDemoSetup(){
        /// Display only the left and right button
        view.mainView.mTopButton.isHidden=true
        view.mainView.mTopRightButton.isHidden=true
        view.mainView.mBottomRightButton.isHidden=true
        view.mainView.mBottomButton.isHidden=true
        view.mainView.mBottomLeftButton.isHidden=true
        view.mainView.mTopLeftButton.isHidden=true
    }
 
    func getBoardSchemaImage(baseOnNodeType nodeType: NodeType) -> UIImage? {
        guard let schemaImageName = nodeType.schemaImageName else { return nil }
        return UIImage(named: schemaImageName, in: STUI.bundle, compatibleWith: nil)
    }
}

private extension BeamFormingPresenter {

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
