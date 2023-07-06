//
//  AudioClassificationViewController.swift
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

final class AudioClassificationViewController: DemoNodeViewController<AudioClassificationDelegate, AudioClassificationView> {
    
    var mCurrentAudioClass: AudioClass?
    
    var audioSceneView: BaseAudioClassView?
    var babyCryingView: BaseAudioClassView?
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.audioClassification.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        guard let audioSceneView = AudioSceneView.make(with: STDemos.bundle) as? AudioSceneView else { return }
        self.audioSceneView = audioSceneView
        
        guard let babyCryingView = BabyCryingView.make(with: STDemos.bundle) as? BabyCryingView else { return }
        self.babyCryingView = babyCryingView
        
        deselectAllImages()
        
        presenter.doInitialRead()
    }
    
    private func deselectAllImages(){
        audioSceneView?.deselectAll()
        babyCryingView?.deselectAll()
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateAudioClassificationUI(with: sample)
        }
    }

}
