//
//  ActivityRecognitionViewController.swift
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

final class ActivityRecognitionViewController: DemoNodeViewController<ActivityRecognitionDelegate, ActivityRecognitionView> {
    
    var mCurrentActivity: ActivityType?
    
    var motionView: ARBaseView?
    var mlcView: ARBaseView?
    var ignView: ARBaseView?
    var gpmView: ARBaseView?
    var adultPresenceView: ARBaseView?
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.activityRecognition.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        guard let arMotionView = ARMotionView.make(with: STDemos.bundle) as? ARMotionView else { return }
        self.motionView = arMotionView
        
        guard let arMLCView = ARMLCView.make(with: STDemos.bundle) as? ARMLCView else { return }
        self.mlcView = arMLCView
        
        guard let arIGNView = ARIGNView.make(with: STDemos.bundle) as? ARIGNView else { return }
        self.ignView = arIGNView
   
        guard let arGMPView = ARGMPView.make(with: STDemos.bundle) as? ARGMPView else { return }
        self.gpmView = arGMPView
        
        guard let arAdultPresenceView = AdultPresenceMLCView.make(with: STDemos.bundle) as? AdultPresenceMLCView else { return }
        self.adultPresenceView = arAdultPresenceView
        
        deselectAllImages()
        
        presenter.doInitialRead()
    }
    
    private func deselectAllImages(){
        motionView?.deselectAll()
        gpmView?.deselectAll()
        ignView?.deselectAll()
        mlcView?.deselectAll()
        adultPresenceView?.deselectAll()
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateActivityRecognitionUI(with: sample)            
        }
    }
}
