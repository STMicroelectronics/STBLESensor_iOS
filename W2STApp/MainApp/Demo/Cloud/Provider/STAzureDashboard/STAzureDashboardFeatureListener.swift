//
//  STAzureDashboardFeatureListener.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 12/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation
import SwiftyJSON

class STAzureDashboardFeatureListener: BlueMSSubSampligFeatureDelegate {
    
    /**
     * test if a feature is supported by this class
     *
     * -Param feature to test
     * -Returns true if the feature can send data to the cloud using this service
     */
    static public func isSupportedFeature(_ feature:BlueSTSDKFeature) -> Bool{
        return (feature is BlueSTSDKFeatureAcceleration) ||
            (feature is BlueSTSDKFeatureMagnetometer) ||
            (feature is BlueSTSDKFeatureGyroscope) ||
            (feature is BlueSTSDKFeatureTemperature) ||
            (feature is BlueSTSDKFeaturePressure) ||
            (feature is BlueSTSDKFeatureHumidity);
        
    }
    
    private let mClient:STAzureDashboardClient
       
       init(client:STAzureDashboardClient, minUpdateInterval : TimeInterval = BlueMSSubSampligFeatureDelegate.DEFAULT_MIN_UPDATE_INTERVAL_S){
           mClient = client
           super.init(minUpdateInterval: minUpdateInterval)
        mClient.reportTelemetryInterval(seconds: minUpdateInterval)
       }
       
       private func buildJsonSample(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample)->JSON?{
           switch feature {
               case is BlueSTSDKFeatureAcceleration:
                   return buildAccelerationJson(sample)
               case is BlueSTSDKFeatureGyroscope:
                   return buildGyroscopeJson(sample)
               case is BlueSTSDKFeatureMagnetometer:
                   return buildMagnetometerJson(sample)
               case is BlueSTSDKFeatureTemperature:
                   return buildTemperatureJson(sample)
               case is BlueSTSDKFeaturePressure:
                   return buildPressureJson(sample)
               case is BlueSTSDKFeatureHumidity:
                   return buildHunidityJson(sample)
               default:
                   return nil
           }
       }
       
       public override func featureHasNewUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
           if let jsonObj = buildJsonSample(feature, sample: sample){
               if let objStr = jsonObj.rawString(){
                   if(mClient.isConnected){
                       mClient.sendTelemetryData(messageStr: objStr)
                   }
               }
           }
       }
       
       private func buildAccelerationJson(_ sample:BlueSTSDKFeatureSample)->JSON{
           var jsonObj = JSON()
           jsonObj["accX"].floatValue = BlueSTSDKFeatureAcceleration.getAccX(sample)
           jsonObj["accY"].floatValue = BlueSTSDKFeatureAcceleration.getAccY(sample)
           jsonObj["accZ"].floatValue = BlueSTSDKFeatureAcceleration.getAccZ(sample)
           return jsonObj
       }
       
       private func buildGyroscopeJson(_ sample:BlueSTSDKFeatureSample)->JSON{
           var jsonObj = JSON()
           jsonObj["gyrX"].floatValue = BlueSTSDKFeatureGyroscope.getGyroX(sample)
           jsonObj["gyrY"].floatValue = BlueSTSDKFeatureGyroscope.getGyroY(sample)
           jsonObj["gyrZ"].floatValue = BlueSTSDKFeatureGyroscope.getGyroZ(sample)
           return jsonObj
       }
       
       private func buildMagnetometerJson(_ sample:BlueSTSDKFeatureSample)->JSON{
           var jsonObj = JSON()
           jsonObj["magX"].floatValue = BlueSTSDKFeatureMagnetometer.getMagX(sample)
           jsonObj["magY"].floatValue = BlueSTSDKFeatureMagnetometer.getMagY(sample)
           jsonObj["magZ"].floatValue = BlueSTSDKFeatureMagnetometer.getMagZ(sample)
           return jsonObj
       }
       
       private func buildTemperatureJson(_ sample:BlueSTSDKFeatureSample)->JSON{
           var jsonObj = JSON()
           jsonObj["Temperature"].floatValue = BlueSTSDKFeatureTemperature.getTemperature(sample)
           return jsonObj
       }
       
       private func buildHunidityJson(_ sample:BlueSTSDKFeatureSample)->JSON{
           var jsonObj = JSON()
           jsonObj["Humidity"].floatValue = BlueSTSDKFeatureHumidity.getHumidity(sample)
           return jsonObj
       }
       
       private func buildPressureJson(_ sample:BlueSTSDKFeatureSample)->JSON{
           var jsonObj = JSON()
           jsonObj["Pressure"].floatValue = BlueSTSDKFeaturePressure.getPressure(sample)
           return jsonObj
       }
}
