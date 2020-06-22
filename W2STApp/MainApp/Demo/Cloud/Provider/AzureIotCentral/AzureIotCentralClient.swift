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
import AzureIoTHubClient
import SwiftyJSON

internal class AzureIotCentralClient : BlueMSCloudIotClient{
    
    private let deviceId:String
    private let scopeId:String
    private let symKey:String
    
    private var networkQueue = DispatchQueue(label: "IoTCentral I/O")
    private var doWork:DispatchWorkItem!
    
    private var iotHubClientHandle: IOTHUB_CLIENT_LL_HANDLE?;
    
    init( deviceId:String,scopeId:String, symKey:String){
        self.deviceId = deviceId
        self.scopeId = scopeId
        self.symKey = symKey;
    }
    
    var isConnected: Bool = false
    
    func connect(_ onComplete: OnIotClientActionCallback?) {
        doWork = DispatchWorkItem{ [weak self] in
            guard let client = self else{
                return
            }
            guard let device = client.iotHubClientHandle else {
                client.networkQueue.asyncAfter(deadline: .now() + 1.0, execute: client.doWork)
                return
            }
            IoTHubClient_LL_DoWork(device)
            client.networkQueue.asyncAfter(deadline: .now() + 0.2, execute: client.doWork)
        }
        networkQueue.async(execute: doWork)
        buildConnectionString{ cs in
            guard let connectionString = cs else {
                let error  = NSError(domain: "Error provisioning the device", code: 0x00, userInfo: nil);
                onComplete?(error)
                return
            }
            self.iotHubClientHandle = IoTHubClient_LL_CreateFromConnectionString(connectionString, MQTT_Protocol)
            self.isConnected = true
            onComplete?(nil)
        }
        
    }
    
    private let mySendConfirmationCallback: IOTHUB_CLIENT_EVENT_CONFIRMATION_CALLBACK = { result, _ in
        
        if (result == IOTHUB_CLIENT_CONFIRMATION_OK) {
            print("message Sent")
        } else {
            print ("message fail")
        }
    }
    
    func sendTelemetryData(messageStr:String){
        guard isConnected else {
            return
        }
        let messageHandle: IOTHUB_MESSAGE_HANDLE = IoTHubMessage_CreateFromByteArray(messageStr, messageStr.utf8.count)
        
        if (messageHandle != OpaquePointer.init(bitPattern: 0)) {
            
            if (IOTHUB_CLIENT_OK == IoTHubClient_LL_SendEventAsync(iotHubClientHandle, messageHandle, mySendConfirmationCallback, nil)) {
                print("message Sent async")
            }
        }
    }
    
    func disconnect(_ onComplete: OnIotClientActionCallback?) {
        isConnected = false
        IoTHubClient_LL_Destroy(iotHubClientHandle)
        iotHubClientHandle = nil
        onComplete?(nil)
    }
    
    private static let DEFAULT_EXPIRATION_S = TimeInterval(6*60*60) // 6 hours
    
    private static let ENDPOINT =  "global.azure-devices-provisioning.net"
    
    private func buildConnectionString( onConnectionStringReady:@escaping ((String?)->Void)){
        let expireDate:Int64 = Int64(Date().timeIntervalSince1970 + AzureIotCentralClient.DEFAULT_EXPIRATION_S)
        let uri = scopeId+"%2fregistrations%2f"+deviceId
        let deviceKey = computeKey(masterKey: symKey, registationId: deviceId)
        let sig = BlueMSAzureIotSignature.signature(forUri: uri, expireTime: expireDate, deviceKey: deviceKey);
        let sasKey = "SharedAccessSignature sr=\(scopeId)%2fregistrations%2f\(deviceId)&sig=\(sig)&skn=registration&se=\(expireDate)"
        requestRegistrationId(sasKey: sasKey){ opId in
            guard let operationId = opId else{
                return
            }
            self.getAssignment(deviceKey: deviceKey, sasKey: sasKey, operationId: operationId, onConnectionStringReady: onConnectionStringReady)
        }
        
    }
    
    private func requestRegistrationId(sasKey:String,
                               onOperationIdIsReady:@escaping ((String?)->Void)){
        let requestUrl = URL(string:String(format: "https://%@/%@/registrations/%@/register?api-version=2018-09-01-preview",
                                           AzureIotCentralClient.ENDPOINT,scopeId,deviceId))
        guard let url = requestUrl else{
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod="PUT"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(AzureIotCentralClient.ENDPOINT, forHTTPHeaderField: "Host")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("utf-8", forHTTPHeaderField: "charset")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("prov_device_client/1.0", forHTTPHeaderField: "UserAgent")
        request.addValue(sasKey, forHTTPHeaderField: "Authorization")
        request.httpBody = "{\"registrationId\":\"\(deviceId)\"}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let rawData = data else{
                return
            }
            let respData = try? JSON(data:rawData)
            onOperationIdIsReady(respData?["operationId"].string)
        }
        task.resume()
        
    }
    
    private func getAssignment(deviceKey:String, sasKey:String, operationId:String,onConnectionStringReady:@escaping ((String?)->Void)){
        let requestUrl = URL(string:String(format: "https://%@/%@/registrations/%@/operations/%@?api-version=2018-09-01-preview",
                                           AzureIotCentralClient.ENDPOINT,scopeId,deviceId,operationId))
        guard let url = requestUrl else{
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod="GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(AzureIotCentralClient.ENDPOINT, forHTTPHeaderField: "Host")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("utf-8", forHTTPHeaderField: "charset")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("prov_device_client/1.0", forHTTPHeaderField: "UserAgent")
        request.addValue(sasKey, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){ [weak self] data, response, error in
            guard let rawData = data else{
                return
            }
            let respData = try? JSON(data:rawData)
            if let status = respData?["status"]{
                if status == "assigned"{
                    if let hub = respData?["registrationState"]["assignedHub"],
                        let deviceId = respData?["registrationState"]["deviceId"]{
                        onConnectionStringReady("HostName=\(hub);DeviceId=\(deviceId);SharedAccessKey=\(deviceKey)")
                        return
                    }
                }else if status == "assigning"{
                    self?.networkQueue.asyncAfter(deadline: .now() + 2.0){ [weak self] in
                        self?.getAssignment(deviceKey: deviceKey, sasKey: sasKey,
                                           operationId: operationId,
                                           onConnectionStringReady: onConnectionStringReady)
                    }
                    return
                }
            }
            onConnectionStringReady(nil)
        }
        task.resume()
    }
    
    private func computeKey(masterKey:String, registationId:String)->String{
        let keyBytes = Data(base64Encoded: masterKey.data(using: .utf8)!)!
        let res = Data(registationId.utf8).getSHA256HMac(key: keyBytes)
        return res.base64EncodedString()
    }
    
}
