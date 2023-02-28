//
//  BlueSTSDKFeatureAccelerometerEvent+Extensions.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 29/03/21.
//
//  Code Duplicated from: W2STAccEventViewController.h/.m
//

import Foundation

public extension BlueSTSDKFeatureAccelerometerEvent {
    var supportedTypes: [BlueSTSDKFeatureAccelerationDetectableEventType] {
        switch parentNode.type {
            case .STEVAL_WESU1:
                return [
                    .eventTypeNone,
                    .eventTypeMultiple
                ]
            case .STEVAL_IDB008VX:
                return [
                    .eventTypeNone,
                    .eventTypeFreeFall,
                    .eventTypeSingleTap,
                    .eventTypeWakeUp,
                    .eventTypeTilt,
                    .eventTypePedometer
                ]
            case .sensor_Tile_Box:
                return [
                    .eventTypeNone,
                    .eventTypeOrientation,
                    .eventTypeDoubleTap,
                    .eventTypeFreeFall,
                    .eventTypeSingleTap,
                    .eventTypeTilt,
                    .eventTypeWakeUp
                ]
            case .STEVAL_BCN002V1:
                return [
                    .eventTypeNone,
                    .eventTypeWakeUp,
                    .eventTypeSingleTap,
                    .eventTypeTilt,
                    .eventTypePedometer,
                    .eventTypeFreeFall
                ]
            default:
                return [
                    .eventTypeNone,
                    .eventTypeOrientation,
                    .eventTypeMultiple,
                    .eventTypeFreeFall,
                    .eventTypeSingleTap,
                    .eventTypeDoubleTap,
                    .eventTypeWakeUp,
                    .eventTypeTilt,
                    .eventTypePedometer
                ]
        }
    }
    
    func disableEvent(_ event: BlueSTSDKFeatureAccelerationDetectableEventType) {
        self.enable(event, enable: false)
    }
    
    func enableEvent(_ event: BlueSTSDKFeatureAccelerationDetectableEventType) {
        self.enable(event, enable: true)
    }
}
