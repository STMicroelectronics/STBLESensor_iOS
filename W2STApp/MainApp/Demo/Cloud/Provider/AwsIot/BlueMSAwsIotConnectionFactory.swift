
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
import AWSIoT

public class BlueMSAwsIotConnectionFactory : BlueMSCloudIotConnectionFactory{
    private static let ENPOINT_FORMAT = "[-_\\w]*\\.iot\\.([-_\\w]*)\\.amazonaws\\.com";
    private static let PKSCS12_CERTIFICATE_NAME = "AwsIotCertificate"
    private static let PKSCS12_KEY_PASSWORD = "AwsIotPassword"
    private static let CONNECTION_CONF_NAME = "BlueMsAwsIot"
    
    private let certificateUrl:URL;
    private let privateKeyUrl:URL;
    private let enpoint:AWSEndpoint;
    private let clientId:String;
    
    private static func extractRegion(serviceUrl url:String)-> AWSRegionType{
        let validator = try? NSRegularExpression(pattern: BlueMSAwsIotConnectionFactory.ENPOINT_FORMAT,options: .caseInsensitive)
        
        let matchs = validator?.matches(in: url,
                                        options: [],
                                        range: NSRange(location: 0, length: url.count))
        if let results = matchs {
            if !results.isEmpty{
                let matchRange = results[0].range(at: 1)
                if let swiftRange = Range(matchRange, in: url) {
                    return String(url[swiftRange]).aws_regionTypeValue();
                }
            }
        }
        return AWSRegionType.Unknown;
    }
    
    private static func buildAWSEndpiintFromString(endpointUrl:String)->AWSEndpoint{
        let region = extractRegion(serviceUrl:endpointUrl);
        let url = URL(string: endpointUrl);
    
        return AWSEndpoint(region: region, service: .IoTData, url: url!)
    }
    
    public init(endpointUrl: String,deviceId:String, certificate:URL,privateKey:URL){
        self.enpoint = BlueMSAwsIotConnectionFactory.buildAWSEndpiintFromString(endpointUrl: endpointUrl);
        self.clientId = deviceId;
        certificateUrl = certificate;
        privateKeyUrl = privateKey;
    }
    
    private static func getFileContent(fileUrl:URL)->String?{
        return try? String(contentsOf: fileUrl, encoding: .utf8)
    }
    
    public func getSession() -> BlueMSCloudIotClient {
        let certificate = BlueMSAwsIotConnectionFactory.getFileContent(fileUrl: certificateUrl);
        let privateKey =  BlueMSAwsIotConnectionFactory.getFileContent(fileUrl: privateKeyUrl);
        
        let serviceConf = AWSServiceConfiguration(region:  self.enpoint.regionType,
                                                  endpoint: enpoint,
                                                  credentialsProvider: AWSAnonymousCredentialsProvider());
        let p12Data = BlueMSAwsIotConnectionFactory.getP12CertificateFormat(certificateName: BlueMSAwsIotConnectionFactory.PKSCS12_CERTIFICATE_NAME,
                                                                            certificateValue: certificate!,
                                                                            password: BlueMSAwsIotConnectionFactory.PKSCS12_KEY_PASSWORD,
                                                                            privateKey: privateKey!);
        
        AWSIoTManager.importIdentity( fromPKCS12Data: p12Data!,
                                      passPhrase: BlueMSAwsIotConnectionFactory.PKSCS12_KEY_PASSWORD,
                                      certificateId:BlueMSAwsIotConnectionFactory.PKSCS12_CERTIFICATE_NAME)
        AWSIoTDataManager.register(with: serviceConf!, forKey: BlueMSAwsIotConnectionFactory.CONNECTION_CONF_NAME);
        
        let manager = AWSIoTDataManager(forKey: BlueMSAwsIotConnectionFactory.CONNECTION_CONF_NAME);
        return AwsCloudIotClient(manager,authId: BlueMSAwsIotConnectionFactory.PKSCS12_CERTIFICATE_NAME,clientId: clientId);
    }
    
    public func getDataUrl() -> URL? {
        return nil;
    }
    
    public func getFeatureDelegate(withSession session: BlueMSCloudIotClient) -> BlueSTSDKFeatureDelegate {
        let awsConnection = (session as! AwsCloudIotClient).connection
        return AwsMqttFeatureListener(clientId: clientId, connection: awsConnection);
    }
    
    public func isSupportedFeature(_ feature: BlueSTSDKFeature) -> Bool {
        return true;
    }
    
    public func enableCloudFwUpgrade(for node: BlueSTSDKNode, connection cloudConnection: BlueMSCloudIotClient, callback: @escaping OnFwUpgradeAvailableCallback) -> Bool {
        return false;
    }
    
    private static func getP12CertificateFormat(certificateName:String, certificateValue:String, password:String, privateKey:String)->Data?{
        let p12 = PKSCS12_createCertificate(certificateName: certificateName, certificateValue: certificateValue,
                                            password: password, privateKeyValue: privateKey);
        let p12File = PKSCS12_storeKeyOnTempFile(certificate: p12);
        return loadFile(url: p12File);
    }
    
    private static func loadFile(url:URL?)->Data?{
        guard url != nil else{
            return nil;
        }
        return try? Data(contentsOf: url!)
    }
    
    private class AwsCloudIotClient : BlueMSCloudIotClient{
        
        public let connection:AWSIoTDataManager;
        private var connectionCallback:OnIotClientActionCallback?;
        private let clientId:String;
        private let certificateId:String;
        
        public init(_ dataManager:AWSIoTDataManager,authId:String, clientId:String){
            self.connection = dataManager;
            self.clientId=clientId;
            self.certificateId = authId;
        }
        
        func connect(_ callback: OnIotClientActionCallback? = nil) {
            
            connectionCallback=callback;
            connection.connect(withClientId: clientId, cleanSession: true, certificateId: certificateId,
                               statusCallback:mqttEventCallback);
        }
        
        func mqttEventCallback( _ status: AWSIoTMQTTStatus ){
            if(status == .connected || status == .disconnected){
                connectionCallback?(nil)
            }
            if( status == .connectionError){
                let error = NSError(domain: "Aws Iot Connection Error", code: status.rawValue, userInfo: nil);
                connectionCallback?(error)
            }
            if(status == .connectionRefused){
                let error = NSError(domain: "Aws Iot Connection Refused", code: status.rawValue, userInfo: nil);
                connectionCallback?(error)
            }
            if(status == .protocolError){
                let error = NSError(domain: "Aws Iot Protocol Error", code: status.rawValue, userInfo: nil);
                connectionCallback?(error)
            }
        }

        func disconnect(_ callback: OnIotClientActionCallback? = nil) {
            connectionCallback=callback;
            connection.disconnect()
        }
        
        func isConnected() -> Bool {
            return connection.getConnectionStatus() == .connected;
        }
        
    }
    
    
    
}
