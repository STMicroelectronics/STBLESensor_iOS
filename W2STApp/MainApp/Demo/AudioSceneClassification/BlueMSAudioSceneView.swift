//
//  BlueMSAudioSceneView.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 25/09/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation
class AudioSceneView : UIView, BlueMSAudioClassView{
    typealias ActivityType = BlueSTSDKFeatureAudioCalssification.AudioClass
    
    @IBOutlet var mContentView: UIView!
    @IBOutlet weak var inDoorImage: UIImageView!
    @IBOutlet weak var outDoorImage: UIImageView!
    @IBOutlet weak var inVehicleImage: UIImageView!
    
    lazy var activityToImage: [ActivityType : UIImageView] = {
        return [
            .Indoor : inDoorImage,
            .Outdoor: outDoorImage,
            .InVehicle: inVehicleImage
        ]
    }();
        
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    
    func loadViewFromNib() {
        Bundle.main.loadNibNamed("AudioSceneView", owner: self, options: nil)
        
        mContentView.frame = bounds
        mContentView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(mContentView)
    }
    
}
