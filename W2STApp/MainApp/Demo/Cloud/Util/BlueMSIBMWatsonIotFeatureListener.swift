
import Foundation
import MQTTFramework

public class BlueMsIBMWatsonIotFeatureListener : BlueMSSubSampligFeatureDelegate{
    
    let mSession: MCMQTTSession
    
    public init(session:MCMQTTSession, minUpdateInterval:TimeInterval){
        mSession = session;
        super.init(minUpdateInterval: minUpdateInterval)
    }
    
    public override func featureHasNewUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        guard mSession.status == .connected else {
            return
        }
        
        let topic = "iot-2/evt/"+feature.topicName+"/fmt/json"
        let dataDescription = feature.getFieldsDesc()
        let dataDict = sample.toDict(description: dataDescription)
        let jsonData = [ "d": dataDict ]
        
        let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
        if let messageData = data {
            mSession.publishData(messageData, onTopic: topic, retain: false, qos: .atMostOnce)
        }
    }
}
