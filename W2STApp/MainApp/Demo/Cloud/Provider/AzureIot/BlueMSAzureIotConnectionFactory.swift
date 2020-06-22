/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
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
import MQTTFramework

public class Dummy : NSObject,BlueSTSDKFeatureDelegate{
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
    }
}

public class BlueMSAzureIotConnectionFactory : BlueMSCloudIotConnectionFactory{
    
    private let param:BlueMSAzureIotConnectionParameters;
    
    public init(_ param:BlueMSAzureIotConnectionParameters){
        self.param = param
    }

    private static let HUB_PORT = UInt32(8883)
    private static let MQTT_USER_FORMAT="%@/%@/api-version=2016-11-14"
    private static let TOKEN_VALIDITY_S = TimeInterval(60*60*24) // 1 day
    private static let MQTT_PASSWORD_RESOURCE_URI_FORMAT = "%@%%2Fdevices%%2F%@"
    private static let MQTT_PASSWORD_FORMAT = "SharedAccessSignature sr=%@&sig=%@&se=%lld"
    
    private func getMqttUser()->String{
        return String(format: BlueMSAzureIotConnectionFactory.MQTT_USER_FORMAT,
                      param.hostName,param.deviceId);
    }
    
    private func getMqttPassowrd()->String{
        let expireDate:Int64 = Int64(Date().timeIntervalSince1970 + BlueMSAzureIotConnectionFactory.TOKEN_VALIDITY_S);
        let uri = String(format: BlueMSAzureIotConnectionFactory.MQTT_PASSWORD_RESOURCE_URI_FORMAT,param.hostName, param.deviceId);
        let pass = BlueMSAzureIotSignature.signature(forUri: uri, expireTime: expireDate, deviceKey: param.sharedAccessKey);
        return String(format: BlueMSAzureIotConnectionFactory.MQTT_PASSWORD_FORMAT, uri,pass,expireDate);
    }
    
    
    /**
     * build a session object for connect to a specific cloud service
     *
     * @return mqtt object to use for connect and send data to the cloud service
     */   
    public func getSession() -> BlueMSCloudIotClient {
        let transport = MCMQTTCFSocketTransport();
        transport.host = param.hostName;
        transport.port = BlueMSAzureIotConnectionFactory.HUB_PORT;
        transport.tls=true;
        
        let session = MCMQTTSession(clientId: param.deviceId,
                                  userName: getMqttUser(),
                                  password: getMqttPassowrd())
        session?.transport = transport;
        
        return BlueMSCloudIotMQTTClient(session!);
    }
        
    public func getFeatureDelegate(withSession session: BlueMSCloudIotClient, minUpdateInterval: TimeInterval) -> BlueSTSDKFeatureDelegate {
        let mqttClient = session as! BlueMSCloudIotMQTTClient;
        return BlueMSAzureIotFeatureListener(conneciton: mqttClient.connection, deviceId: param.deviceId,minUpdateInterval:minUpdateInterval);
    }
    
    public func getDataUrl() -> URL? {
        return nil;
    }
    
    public func isSupportedFeature(_ feature: BlueSTSDKFeature) -> Bool {
        return BlueMSCloudUtil.isCloudSupportedFeature(feature);
    }
    
    public func enableCloudFwUpgrade(for node: BlueSTSDKNode, connection: BlueMSCloudIotClient,
                                     callback:@escaping OnFwUpgradeAvailableCallback) -> Bool {
        return false;
    }
    
    
}
