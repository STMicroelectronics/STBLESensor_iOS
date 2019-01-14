import Foundation
import BlueSTSDK
import AWSIoT

public class AwsMqttFeatureListener: BlueMSSubSampligFeatureDelegate{
    
    private let mClientId:String;
    private let mCloudConnection:AWSIoTDataManager;
    
    public init(clientId:String,connection:AWSIoTDataManager, minUpdateInterval:TimeInterval){
        self.mClientId=clientId;
        self.mCloudConnection = connection;
        super.init(minUpdateInterval: minUpdateInterval)
    }
    
    public override func featureHasNewUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        guard mCloudConnection.getConnectionStatus() == .connected else{
            return;
        }
        
        let fields = feature.getFieldsDesc();
        let dataDict = sample.toDict(description: fields)
        let topic = feature.topicName
        
        let data = try? JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
        if let messageData = data {
            mCloudConnection.publishData(messageData, onTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce)
        }
    }
    
}//AwsMqttFeatureListener
