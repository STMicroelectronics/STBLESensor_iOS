//
//  BlueMSSubSamplingFeatureListener.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 16/01/2018.
//  Copyright © 2018 STMicroelectronics. All rights reserved.
//

import Foundation

public class BlueMSSubSampligFeatureDelegate :NSObject, BlueSTSDKFeatureDelegate{
    
    public static let DEFAULT_MIN_UPDATE_INTERVAL_S = TimeInterval(5.0)
    private let mSerialQueue = DispatchQueue(label: "BlueMSSubSampligFeatureDelegateSerializer")

    private let mMinUpdateInterval : TimeInterval;
    private var mLastFeatureUpdate = Dictionary<String,Date>()
  
    public init(minUpdateInterval : TimeInterval = BlueMSSubSampligFeatureDelegate.DEFAULT_MIN_UPDATE_INTERVAL_S) {
        mMinUpdateInterval = minUpdateInterval
        super.init();
    }
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let featureName = feature.name
        if(featureNeedsUpdate(featureName,updateTime: sample.notificaitonTime)){
            featureHasNewUpdate(feature, sample: sample)
            mSerialQueue.sync {
                mLastFeatureUpdate[featureName]=sample.notificaitonTime
            }
        }
    }
    
    public func featureHasNewUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample){}
    
    private func featureNeedsUpdate(_ featureName:String, updateTime:Date) -> Bool{
        let lastUpdate = mSerialQueue.sync { mLastFeatureUpdate[featureName] }
        if(lastUpdate == nil){
            return true
        }
        let timeFromLastUpdate = -lastUpdate!.timeIntervalSince(updateTime)
        return timeFromLastUpdate>=mMinUpdateInterval;
    }
}
