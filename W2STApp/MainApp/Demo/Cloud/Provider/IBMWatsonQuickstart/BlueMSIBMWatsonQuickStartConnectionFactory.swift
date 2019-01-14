/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
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
 * OF */

import Foundation
import MQTTClient

public class BlueMSIBMWatsonQuickStartConnectionFactory : BlueMSCloudIotConnectionFactory{
  
    private static let DATA_URL_FORMAT = "https://quickstart.internetofthings.ibmcloud.com/#/device/%@/sensor/"
    private static let MQTT_BROKER = "quickstart.messaging.internetofthings.ibmcloud.com"
    private static let MQTT_BROKER_PORT = UInt32(8883)
    private static let MQTT_CLIENT_ID_FORMAT = "d:quickstart:%@:%@"
    
    private let mDeviceType:String
    private let mDeviceId:String
    
    public init(deviceType:String,deviceId:String){
        mDeviceId = deviceId
        mDeviceType = deviceType
    }
    
    public func getDataUrl() -> URL? {
        let urlStr = String(format: BlueMSIBMWatsonQuickStartConnectionFactory.DATA_URL_FORMAT,
                            mDeviceId)
        return URL(string: urlStr)
    }
    
    public func getSession() -> BlueMSCloudIotClient {
        let transport = MCMQTTCFSocketTransport();
        transport.host = BlueMSIBMWatsonQuickStartConnectionFactory.MQTT_BROKER;
        transport.port = BlueMSIBMWatsonQuickStartConnectionFactory.MQTT_BROKER_PORT;
        transport.tls=true;
        
        let clientId = String(format:BlueMSIBMWatsonQuickStartConnectionFactory.MQTT_CLIENT_ID_FORMAT,
                              mDeviceType,mDeviceId)
        let session = MCMQTTSession(clientId: clientId)
        session?.transport = transport
        return BlueMSCloudIotMQTTClient(session!)
    }
    
    public func getFeatureDelegate(withSession session: BlueMSCloudIotClient, minUpdateInterval: TimeInterval) -> BlueSTSDKFeatureDelegate {
        let mqttClient = session as! BlueMSCloudIotMQTTClient;
        return BlueMsIBMWatsonIotFeatureListener(session: mqttClient.connection,minUpdateInterval:minUpdateInterval);
    }
    
    public func isSupportedFeature(_ feature: BlueSTSDKFeature) -> Bool {
        return BlueMSCloudUtil.isCloudSupportedFeature(feature)
    }
    
    public func enableCloudFwUpgrade(for node: BlueSTSDKNode, connection cloudConnection: BlueMSCloudIotClient, callback: @escaping OnFwUpgradeAvailableCallback) -> Bool {
        return false
    }
    
}
