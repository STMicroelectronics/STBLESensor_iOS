//
//  BabyCryingView.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 25/09/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation

class BabyCryingView : UIView, BlueMSAudioClassView{
    typealias ActivityType = BlueSTSDKFeatureAudioCalssification.AudioClass
    
    @IBOutlet var mContentView: UIView!
    @IBOutlet weak var cryingImage: UIImageView!
    @IBOutlet weak var notCryingImage: UIImageView!
        
    lazy var activityToImage: [ActivityType : UIImageView] = {
        return [
            .Unknown : notCryingImage,
            .BabyIsCrying: cryingImage
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
        Bundle.main.loadNibNamed("BabyCryingView", owner: self, options: nil)
        
        mContentView.frame = bounds
        mContentView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(mContentView)
    }
    
}
