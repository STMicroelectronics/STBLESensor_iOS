//
//  BlueMSSubSamplingFeatureListener.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 16/01/2018.
//  Copyright © 2018 STMicroelectronics. All rights reserved.
//

import Foundation
import BlueSTSDK

public class BlueMSSubSampligFeatureDelegate: NSObject, BlueSTSDKFeatureDelegate {
    public static let DEFAULT_MIN_UPDATE_INTERVAL_S: TimeInterval = 5
    public static let DEFAULT_ACC_EVENTS_UPDATE_INTERVAL: TimeInterval = 0.5
    private let mSerialQueue = DispatchQueue(label: "BlueMSSubSampligFeatureDelegateSerializer")

    private let mMinUpdateInterval: TimeInterval
    private let accEventsUpdateInterval: TimeInterval
    private var mLastFeatureUpdate = Dictionary<String,Date>()
    private var lastAccEventUpdate: Date?
    private var lastAccEvent: BlueSTSDKFeatureAccelerometerEventType?
  
    public init(minUpdateInterval: TimeInterval = BlueMSSubSampligFeatureDelegate.DEFAULT_MIN_UPDATE_INTERVAL_S,
                accEventsUpdateInterval: TimeInterval = BlueMSSubSampligFeatureDelegate.DEFAULT_ACC_EVENTS_UPDATE_INTERVAL) {
        self.mMinUpdateInterval = minUpdateInterval
        self.accEventsUpdateInterval = accEventsUpdateInterval
        
        super.init()
    }
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        if featureNeedsUpdate(feature, sample: sample, updateTime: sample.notificaitonTime) {
            featureHasNewUpdate(feature, sample: sample)
            
            mSerialQueue.sync {
                mLastFeatureUpdate[feature.name] = sample.notificaitonTime
            }
        }
    }
    
    public func featureHasNewUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {}
    
    private func featureNeedsUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample, updateTime: Date) -> Bool {
        if feature is BlueSTSDKFeatureAccelerometerEvent {
            guard let date = lastAccEventUpdate else { return true }
            
            let event = BlueSTSDKFeatureAccelerometerEvent.getAccelerationEvent(sample)
            switch event {
                case .orientationTopRight,
                     .orientationBottomRight,
                     .orientationBottomLeft,
                     .orientationTopLeft,
                     .orientationUp,
                     .orientationDown,
                     .tilt,
                     .freeFall,
                     .singleTap,
                     .doubleTap,
                     .wakeUp,
                     .pedometer:
                    
                    if event != lastAccEvent {
                        let timeFromLastUpdate = -date.timeIntervalSince(updateTime)
                        return timeFromLastUpdate >= accEventsUpdateInterval
                    } else {
                        return false
                    }
                    
                case .noEvent,
                     .error:
                    
                    return false
                    
                @unknown default:
                    return false
            }
            
        } else {
            let lastUpdate = mSerialQueue.sync { mLastFeatureUpdate[feature.name] }
            
            guard let date = lastUpdate else { return true }
            
            let timeFromLastUpdate = -date.timeIntervalSince(updateTime)
            
            return timeFromLastUpdate >= mMinUpdateInterval
        }
    }
}
