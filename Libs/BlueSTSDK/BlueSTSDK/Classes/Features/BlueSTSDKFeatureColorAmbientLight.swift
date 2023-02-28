//
//  BlueSTSDKFeatureColorAmbientLight.swift
//  BlueSTSDK

import Foundation

public class BlueSTSDKFeatureColorAmbientLight : BlueSTSDKFeature {
    private static let FEATURE_NAME_LUX = "Color Ambient Light";
    
    private static let FEATURE_DATA_NAME_LUX = "Lux"
    private static let FEATURE_UNIT_LUX = "Lux"
    static let DATA_MAX_LUX: Int = 400000
    static let DATA_MIN_LUX: Int = 0
    
    private static let FEATURE_DATA_NAME_UV_INDEX = "UV Index"
    private static let FEATURE_UNIT_LONGITUDE = "Lon"
    static let DATA_MAX_UV_INDEX: Int = 12
    static let DATA_MIN_UV_INDEX: Int = 0

    private static let FEATURE_DATA_NAME_CCT = "Correlated Color Temperature"
    private static let FEATURE_UNIT_CCT = "K"
    static let DATA_MAX_CCT: Int = 20000
    static let DATA_MIN_CCT: Int = 0

    
    private static let LUX_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME_LUX, unit: FEATURE_UNIT_LUX, type: .uInt32, min: NSNumber(value: DATA_MIN_LUX), max: NSNumber(value: DATA_MAX_LUX))
    private static let CCT_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME_CCT, unit: FEATURE_UNIT_CCT, type: .uInt16, min: NSNumber(value: DATA_MIN_CCT), max: NSNumber(value: DATA_MAX_CCT))
    private static let UV_INDEX_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME_UV_INDEX, unit: nil, type: .uInt16, min: NSNumber(value: DATA_MIN_CCT), max: NSNumber(value: DATA_MAX_CCT))
    
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        LUX_FIELD, CCT_FIELD, UV_INDEX_FIELD
    ];
    
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureColorAmbientLight.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureColorAmbientLight.FEATURE_NAME_LUX)
    }
    
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < 8){
            NSException(name: NSExceptionName(rawValue: "Invalid Ambient Light data "),
                        reason: "There are no 8 bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let result0 = (data as NSData).extractLeUInt32 (fromOffset: UInt(offset))
        let result1 = (data as NSData).extractLeUInt16(fromOffset: UInt(offset+4))
        let result2 = (data as NSData).extractLeUInt16(fromOffset: UInt(offset+6))

        return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: [NSNumber(value: result0),
                                                                                                      NSNumber(value: result1),
                                                                                                      NSNumber(value: result2)
                                                                                                     ]), nReadData: 8)
    }
    
    
    /**
     * Return the Lux
     * @param sample data sample
     * @return
     */
    public func getLuxValue(sample: BlueSTSDKFeatureSample?) -> Int {
        if !(sample == nil)  {
            if !(sample!.data.isEmpty){
                if !(sample!.data[0] == nil){
                    return Int(sample!.data[0])
                }
            }
        }
        return 0
    }
    
    /**
     * Return the CCT
     * @param sample data sample
     * @return
     */
    public func getCCTValue(sample: BlueSTSDKFeatureSample?) -> Int {
        if !(sample == nil)  {
            if !(sample!.data.isEmpty){
                if !(sample!.data[1] == nil){
                    return Int(sample!.data[1])
                }
            }
        }
        return 0
    }
    
    /**
     * Return the UV Index
     * @param sample data sample
     * @return
     */
    public func getUVIndexValue(sample: BlueSTSDKFeatureSample?) -> Int {
        if !(sample == nil)  {
            if !(sample!.data.isEmpty){
                if !(sample!.data[2] == nil){
                    return Int(sample!.data[2])
                }
            }
        }
        return 0
    }
    
}
