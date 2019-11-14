
import Foundation
import SwiftyJSON

extension BlueSTSDKFeatureSample{
    private static let TIMESTAMP_KEY = "timestamp"
    
    func toDict(description:[BlueSTSDKFeatureField]) -> Dictionary<String,Any>{
        var sampleDic = Dictionary<String,Any>()
        
        sampleDic[BlueSTSDKFeatureSample.TIMESTAMP_KEY] = timestamp;
        description.enumerated().forEach{index,desc in
            sampleDic[desc.name]=data[index];
        }
        
        return sampleDic;
    }
}

extension BlueSTSDKFeature{
    
    var topicName : String{
        get {
            return name.replacingOccurrences(of: " ", with: "_")
                        .replacingOccurrences(of: "(", with: "")
                        .replacingOccurrences(of: ")", with: "") }
    }
    
}

/*
 * create a class just becouse some ConnectionFactory are implemented in objc, when all are implemented
 * using swift, use a protocol extension...
 */
public class BlueMSCloudUtil : NSObject{
    
    static public func isCloudSupportedFeature(_ feature: BlueSTSDKFeature) -> Bool{
        return (feature is BlueSTSDKFeatureAcceleration) ||
            (feature is BlueSTSDKFeatureActivity) ||
            (feature is BlueSTSDKFeatureBattery) ||
            (feature is BlueSTSDKFeatureCarryPosition) ||
            (feature is BlueSTSDKFeatureCompass) ||
            (feature is BlueSTSDKFeatureDirectionOfArrival) ||
            (feature is BlueSTSDKFeatureGyroscope) ||
            (feature is BlueSTSDKFeatureHumidity) ||
            (feature is BlueSTSDKFeatureLuminosity) ||
            (feature is BlueSTSDKFeatureMagnetometer) ||
            (feature is BlueSTSDKFeatureMemsGesture) ||
            (feature is BlueSTSDKFeatureMemsSensorFusionCompact) ||
            (feature is BlueSTSDKFeatureMemsSensorFusion) ||
            (feature is BlueSTSDKFeatureMicLevel) ||
            (feature is BlueSTSDKFeatureMotionIntensity) ||
            (feature is BlueSTSDKFeaturePedometer) ||
            (feature is BlueSTSDKFeatureProximity) ||
            (feature is BlueSTSDKFeatureProximityGesture) ||
            (feature is BlueSTSDKFeaturePressure) ||
            (feature is BlueSTSDKFeatureCOSensor) ||
            (feature is BlueSTSDKFeatureHeartRate) ||
            (feature is BlueSTSDKFeatureTemperature);
    }
}
