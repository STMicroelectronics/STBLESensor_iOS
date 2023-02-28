//
//  STATConnectionFactory.swift
//  W2STApp
//
//  Created by Dimitri Giani on 30/03/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import BlueSTSDK
import AssetTrackingDataModel
import Foundation
import MQTTClient

public class BlueMSCloudIotSTAssetTrackingClient: BlueMSCloudIotClient {
    public var isConnected: Bool = false
    public func connect(_ onComplete: OnIotClientActionCallback?) {}
    public func disconnect(_ onComplete: OnIotClientActionCallback?) {}
}

public class BlueMSCloudIotSTAssetTrackingFeatureListener: BlueMSSubSampligFeatureDelegate {
    public var canAddSamples = true
    public var samples: [DataSample] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.didUpdateSamples()
            }
        }
    }
    
    public var didUpdateSamples: () -> Void = {}
    
    public override func featureHasNewUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        guard canAddSamples else { return }
        
        switch feature {
            case is BlueSTSDKFeatureTemperature:
                samples.append(
                    DataSample.sensor(data: SensorDataSample(date: sample.notificaitonTime, temperature: BlueSTSDKFeatureTemperature.getTemperature(sample), humidity: nil, pressure: nil, acceleration: nil))
                )
                
            case is BlueSTSDKFeatureHumidity:
                samples.append(
                    DataSample.sensor(data: SensorDataSample(date: sample.notificaitonTime, temperature: nil, humidity: BlueSTSDKFeatureHumidity.getHumidity(sample), pressure: nil, acceleration: nil))
                )
                
            case is BlueSTSDKFeaturePressure:
                samples.append(
                    DataSample.sensor(data: SensorDataSample(date: sample.notificaitonTime, temperature: nil, humidity: nil, pressure: BlueSTSDKFeaturePressure.getPressure(sample), acceleration: nil))
                )
                
            case is BlueSTSDKFeatureAccelerometerEvent:
                guard let value = sample.data.first as? UInt8 else { return }
                samples.append(
                    DataSample.event(data: EventDataSample(date: sample.notificaitonTime, acceleration: nil, accelerationEvents: value.toAccelerationEvents(), currentOrientation: value.convertToNfcOrientation().sensorOrientation))
                )
                
            default:
                break
        }
        
    }
}

class STATConnectionFactory: BlueMSCloudIotConnectionFactory {
    func getSession() -> BlueMSCloudIotClient {
        return BlueMSCloudIotSTAssetTrackingClient()
    }
    
    func getDataUrl() -> URL? {
        nil
    }
    
    func getFeatureDelegate(withSession: BlueMSCloudIotClient, minUpdateInterval: TimeInterval) -> BlueSTSDKFeatureDelegate {
        return BlueMSCloudIotSTAssetTrackingFeatureListener()
    }
    
    func isSupportedFeature(_ feature: BlueSTSDKFeature) -> Bool {
        BlueMSCloudUtil.isCloudSupportedFeatureForSTAT(feature)
    }
    
    func enableCloudFwUpgrade(for: BlueSTSDKNode, connection: BlueMSCloudIotClient, callback: @escaping OnFwUpgradeAvailableCallback) -> Bool {
        false
    }
}
