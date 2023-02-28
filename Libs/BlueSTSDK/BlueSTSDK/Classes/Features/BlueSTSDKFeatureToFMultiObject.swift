//
//  BlueSTSDKFeatureToFMultiObject.swift
//  BlueSTSDK

import Foundation

public class BlueSTSDKFeatureToFMultiObject : BlueSTSDKFeature {
    private static let FEATURE_NAME = "ToF Multi Object";
    private static let FEATURE_UNIT = "mm";
    private static let FEATURE_DATA_NAME = "Obj";
    static let DATA_MAX: Int = 4000
    static let DATA_MIN: Int = 0
    
    static let MAX_OBJ_NUMBER: Int = 4
    
    private static let OBJECT_FOUND_UNIT = "num";
    private static let OBJECT_FOUND_DATA_NAME = "Num";
    
    private static let PRESENCE_FOUND_UNIT = "num";
    private static let PRESENCE_FOUND_DATA_NAME = "Pres";
    
    static let ENABLE_PRESENCE_DETECTION_COMMAND: UInt8 = 0x01
    static let DISABLE_PRESENCE_DETECTION_COMMAND: UInt8 = 0x00
    
    private static let TOF_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME, unit: FEATURE_UNIT, type: .uInt16, min: NSNumber(value: DATA_MIN), max: NSNumber(value: DATA_MAX), plotIt: "true")
    private static let OBJECT_FOUND_FIELD = BlueSTSDKFeatureField(name: OBJECT_FOUND_DATA_NAME, unit: OBJECT_FOUND_UNIT, type: .int8, min: NSNumber(value: 0), max: NSNumber(value: MAX_OBJ_NUMBER), plotIt: "false")
    private static let PRESENCE_FOUND_FIELD = BlueSTSDKFeatureField(name: PRESENCE_FOUND_DATA_NAME, unit: PRESENCE_FOUND_UNIT, type: .int8, min: NSNumber(value: 0), max: NSNumber(value: MAX_OBJ_NUMBER), plotIt: "false")
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        TOF_FIELD, TOF_FIELD, TOF_FIELD, TOF_FIELD, OBJECT_FOUND_FIELD, PRESENCE_FOUND_FIELD
    ];
    
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureToFMultiObject.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureToFMultiObject.FEATURE_NAME)
    }
    
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        
        let intOffset = Int(offset)
        
        /**Number of valid distances**/
        let nObj = (data.count-intOffset)/2
        
        var temp = Array<BlueSTSDKFeatureField?>(repeating: nil, count:(BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER+2))
        
        for i in 0...(BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER-1) {
            temp[i] = BlueSTSDKFeatureField(name: String(BlueSTSDKFeatureToFMultiObject.FEATURE_DATA_NAME+String((i+1))), unit: BlueSTSDKFeatureToFMultiObject.FEATURE_UNIT, type: .uInt16, min: NSNumber(value: BlueSTSDKFeatureToFMultiObject.DATA_MIN), max: NSNumber(value: BlueSTSDKFeatureToFMultiObject.DATA_MAX), plotIt: "true")
        }
        
        temp[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER] = BlueSTSDKFeatureField(name: BlueSTSDKFeatureToFMultiObject.OBJECT_FOUND_DATA_NAME, unit: BlueSTSDKFeatureToFMultiObject.OBJECT_FOUND_UNIT, type: .int8, min: NSNumber(value: 0), max: NSNumber(value: BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER), plotIt: "false")
        
        temp[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER + 1] = BlueSTSDKFeatureField(name: BlueSTSDKFeatureToFMultiObject.OBJECT_FOUND_DATA_NAME, unit: BlueSTSDKFeatureToFMultiObject.OBJECT_FOUND_UNIT, type: .int8, min: NSNumber(value: 0), max: NSNumber(value: BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER), plotIt: "false")
        
    
        var results = Array<NSNumber>(repeating: 0, count:(BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER+2))
        
        if(nObj>0){
            for i in 0...(nObj-1) {
                results[i] = NSNumber(value: (data as NSData).extractLeUInt16(fromOffset: UInt(intOffset + 2*i)))
            }
        }
        
        let j = nObj
        /**Fill the remaining distances**/
        for j in nObj...BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER {
            results[j] = NSNumber(value: 0) //Not a valid Measure
        }
        
        results[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER] = NSNumber(value: nObj)
        
        if(((data.count-intOffset)&0x1)==1){
            results[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER + 1] = NSNumber(value: (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2*nObj)))
        }else{
            results[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER + 1] = NSNumber(value: 0)
        }

        return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: results), nReadData: UInt32(data.count))
    }
    
    
    /**
     *  return the distance for the one object
     * @param sample data sample
     * @param obj_num object number
     * @return
     */
    public func getDistance (sample: BlueSTSDKFeatureSample, obj_num: Int) -> Int {
        if !(sample == nil){
            if (obj_num<BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER) {
                if (sample.data.count > 0){
                    if !(sample.data[obj_num]==nil){
                        return Int(sample.data[obj_num])
                    }
                }
            }
        }
        return 0
    }
    
    /**
     * Return the formatted string for one object distance
     * @param sample data sample
     * @param obj_num object number
     * @return
     */
    public func getDistanceToString (sample: BlueSTSDKFeatureSample, obj_num: Int) -> String? {
        if !(sample == nil){
            if (obj_num<BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER) {
                if (sample.data.count > 0){
                    if !(sample.data[obj_num]==nil){
                        let distance: Int = Int(sample.data[obj_num])
                        if !(distance==0){
                            return String("Distance \(distance) \(BlueSTSDKFeatureToFMultiObject.FEATURE_UNIT)")
                        }else{
                            return String("Distance NaN \(BlueSTSDKFeatureToFMultiObject.FEATURE_UNIT)")
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /**
     *  Return the number found objects
     * @param sample data sample
     * @return
     */
    public func getNumObjects (sample: BlueSTSDKFeatureSample) -> Int {
        if !(sample == nil){
            if (sample.data.count > 0){
                if !(sample.data[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER]==nil){
                    return Int(sample.data[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER])
                }
            }
        }
        return 0
    }
    
    /**
     *  Return the number of found presences
     * @param sample data sample
     * @return
     */
    public func getNumPresence (sample: BlueSTSDKFeatureSample) -> Int {
        if !(sample == nil){
            if (sample.data.count > 0){
                if !(sample.data[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER + 1]==nil){
                    return Int(sample.data[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER + 1])
                }
            }
        }
        return 0
    }
    
    /**
     * return the formatted string for the number of found presences
     * @param sample
     * @return
     */
    public func getNumPresenceToString (sample: BlueSTSDKFeatureSample) -> String? {
        if !(sample == nil){
            if (sample.data.count > 0){
                if !(sample.data[4]==nil){
                    let numPres: Int = Int(sample.data[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER + 1])
                    if(numPres==1){
                        return "Found 1 person"
                    } else if (numPres>1) {
                        return String("Found \(sample.data[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER + 1]) people")
                    } else {
                        return "No Presence Found"
                    }
                }
            }
        }
        return nil
    }
    
    /**
     * return the formatted string for the number of found objects
     * @param sample
     * @return
     */
    public func getNumObjectsToString (sample: BlueSTSDKFeatureSample) -> String? {
        if !(sample == nil){
            if (sample.data.count > 0){
                if !(sample.data[4]==nil){
                    let numObj: Int = Int(sample.data[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER])
                    if(numObj==1){
                        return "Found 1 Object"
                    } else if (numObj>1) {
                        return String("Found \(sample.data[BlueSTSDKFeatureToFMultiObject.MAX_OBJ_NUMBER]) objects")
                    } else {
                        return "No Objects Found"
                    }
                }
            }
        }
        return nil
    }
    
    public func enablePresenceRecognition(f: BlueSTSDKFeature) {
        f.parentNode.writeData(to: f, data: Data([BlueSTSDKFeatureToFMultiObject.ENABLE_PRESENCE_DETECTION_COMMAND]))
    }

    public func disablePresenceRecognition(f: BlueSTSDKFeature){
        f.parentNode.writeData(to: f, data: Data([BlueSTSDKFeatureToFMultiObject.DISABLE_PRESENCE_DETECTION_COMMAND]))
    }
}
