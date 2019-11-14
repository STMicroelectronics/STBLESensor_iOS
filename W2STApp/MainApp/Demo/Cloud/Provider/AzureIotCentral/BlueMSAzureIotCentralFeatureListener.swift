/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

import Foundation
import SwiftyJSON

internal class BlueMSAzureIotCentralFeatureListener : BlueMSSubSampligFeatureDelegate{
    
    private static let SUPPORTED_FEATURE = [
        BlueSTSDKFeatureAcceleration.self,
        BlueSTSDKFeatureGyroscope.self,
        BlueSTSDKFeatureMagnetometer.self,
        BlueSTSDKFeaturePressure.self,
        BlueSTSDKFeatureHumidity.self,
        BlueSTSDKFeatureTemperature.self,
        //BlueSTSDKFeatureFFTAmplitude.self
    ]
    
    static func isSupportingFeature(_ f:BlueSTSDKFeature) -> Bool{
        return SUPPORTED_FEATURE.contains{ type in
            return f.isKind(of: type)
        }
    }
    
    private let mClient:AzureIotCentralClient
    
    init(client:AzureIotCentralClient, minUpdateInterval : TimeInterval = BlueMSSubSampligFeatureDelegate.DEFAULT_MIN_UPDATE_INTERVAL_S){
        mClient = client
        super.init(minUpdateInterval: minUpdateInterval)
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
    
    override func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        if feature is BlueSTSDKFeatureFFTAmplitude {
            sendFFTData(sample)
        }else{
            super.didUpdate(feature, sample: sample)
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
        jsonObj["Accelerometer_X"].floatValue = BlueSTSDKFeatureAcceleration.getAccX(sample)
        jsonObj["Accelerometer_Y"].floatValue = BlueSTSDKFeatureAcceleration.getAccY(sample)
        jsonObj["Accelerometer_Z"].floatValue = BlueSTSDKFeatureAcceleration.getAccZ(sample)
        return jsonObj
    }
    
    private func buildGyroscopeJson(_ sample:BlueSTSDKFeatureSample)->JSON{
        var jsonObj = JSON()
        jsonObj["Gyroscope_X"].floatValue = BlueSTSDKFeatureGyroscope.getGyroX(sample)
        jsonObj["Gyroscope_Y"].floatValue = BlueSTSDKFeatureGyroscope.getGyroY(sample)
        jsonObj["Gyroscope_Z"].floatValue = BlueSTSDKFeatureGyroscope.getGyroZ(sample)
        return jsonObj
    }
    
    private func buildMagnetometerJson(_ sample:BlueSTSDKFeatureSample)->JSON{
        var jsonObj = JSON()
        jsonObj["Magnetometer_X"].floatValue = BlueSTSDKFeatureMagnetometer.getMagX(sample)
        jsonObj["Magnetometer_Y"].floatValue = BlueSTSDKFeatureMagnetometer.getMagY(sample)
        jsonObj["Magnetometer_Z"].floatValue = BlueSTSDKFeatureMagnetometer.getMagZ(sample)
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
    
    private func sendFFTData(_ sample:BlueSTSDKFeatureSample){
        print("Complete: %f",BlueSTSDKFeatureFFTAmplitude.getDataLoadPercentage(sample))
        guard BlueSTSDKFeatureFFTAmplitude.isComplete(sample) else {
            return
        }
        let freqStep = BlueSTSDKFeatureFFTAmplitude.getFrequencySteps(sample)
        let nSample = BlueSTSDKFeatureFFTAmplitude.getNSample(sample)
        guard let xData = BlueSTSDKFeatureFFTAmplitude.getXComponent(sample),
            let yData = BlueSTSDKFeatureFFTAmplitude.getYComponent(sample),
            let zData = BlueSTSDKFeatureFFTAmplitude.getZComponent(sample) else {
                return
        }
        for i in 0..<Int(nSample) {
            var sampleObj = JSON()
            sampleObj["f"].floatValue = freqStep*Float(i)
            sampleObj["FFT_X"].floatValue = xData[i]
            sampleObj["FFT_Y"].floatValue = yData[i]
            sampleObj["FFT_Z"].floatValue = zData[i]
            if let str = sampleObj.rawString(),
                mClient.isConnected {
                mClient.sendTelemetryData(messageStr: str)
            }
        }
    }
}
