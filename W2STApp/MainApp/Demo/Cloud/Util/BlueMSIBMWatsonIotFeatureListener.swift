
import Foundation
import MQTTClient

public class BlueMsIBMWatsonIotFeatureListener: BlueMSSubSampligFeatureDelegate {
    
    let mSession: MQTTSession
    
    public init(session: MQTTSession, minUpdateInterval: TimeInterval) {
        mSession = session
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
        
        if (dataDict["Event"] as? Int == 256) {
            debugPrint("Event 256")
        }
        
        let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
        if let messageData = data {
            mSession.publishData(messageData, onTopic: topic, retain: false, qos: .atMostOnce)
        }
    }
}
