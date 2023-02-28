//
//  BlueSTSDKFeatureGNSS.swift
//  BlueSTSDK

import Foundation

public class BlueSTSDKFeatureGNSS : BlueSTSDKFeature {
    private static let FEATURE_NAME = "Global Navigation Satellite System";
    
    private static let FEATURE_DATA_NAME_LATITUDE = "Latitude"
    private static let FEATURE_UNIT_LATITUDE = "Lat"
    static let DATA_MAX_LATITUDE: Int =  900000000
    static let DATA_MIN_LATITUDE: Int = -900000000
    
    private static let FEATURE_DATA_NAME_LONGITUDE = "Longitude"
    private static let FEATURE_UNIT_LONGITUDE = "Lon"
    static let DATA_MAX_LONGITUDE: Int =  1800000000
    static let DATA_MIN_LONGITUDE: Int = -1800000000

    private static let FEATURE_DATA_NAME_ALTITUDE = "Altitude"
    private static let FEATURE_UNIT_ALTITUDE = "Meter"
    static let DATA_MAX_ALTITUDE: Int = Int.max
    static let DATA_MIN_ALTITUDE: Int = 0
    
    private static let FEATURE_DATA_NAME_NSAT = "Satellites Number"
    private static let FEATURE_UNIT_NSAT = "Num"
    
    private static let FEATURE_DATA_NAME_SIGQUALITY = "Signal Quality"
    private static let FEATURE_UNIT_SIGQUALITY = "dB-Hz"
    
    private static let LATITUDE_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME_LATITUDE, unit: FEATURE_UNIT_LATITUDE, type: .int32, min: NSNumber(value: DATA_MIN_LATITUDE), max: NSNumber(value: DATA_MAX_LATITUDE))
    private static let LONGITUDE_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME_LONGITUDE, unit: FEATURE_UNIT_LONGITUDE, type: .int32, min: NSNumber(value: DATA_MIN_LONGITUDE), max: NSNumber(value: DATA_MAX_LONGITUDE))
    private static let ALTITUDE_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME_ALTITUDE, unit: FEATURE_UNIT_ALTITUDE, type: .int32, min: NSNumber(value: DATA_MIN_ALTITUDE), max: NSNumber(value: DATA_MAX_ALTITUDE))
    private static let NSAT_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME_NSAT, unit: FEATURE_UNIT_NSAT, type: .uInt8, min: NSNumber(value: 0), max: NSNumber(value: 255))
    private static let SIGQUALITY_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME_SIGQUALITY, unit: FEATURE_UNIT_SIGQUALITY, type: .uInt8, min: NSNumber(value: 0), max: NSNumber(value: 255))
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        LATITUDE_FIELD, LONGITUDE_FIELD, ALTITUDE_FIELD, NSAT_FIELD, SIGQUALITY_FIELD
    ];
    
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureGNSS.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureGNSS.FEATURE_NAME)
    }
    
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < 14){
            NSException(name: NSExceptionName(rawValue: "Invalid GNSS data "),
                        reason: "There are no 14 bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let result0 = (data as NSData).extractLeInt32(fromOffset: UInt(offset))
        let result1 = (data as NSData).extractLeInt32(fromOffset: UInt(offset+4))
        let result2 = (data as NSData).extractLeInt32(fromOffset: UInt(offset+8))
        let result3 = data[intOffset+12]
        let result4 = data[intOffset+13]

        return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: [NSNumber(value: result0),
                                                                                                      NSNumber(value: result1),
                                                                                                      NSNumber(value: result2),
                                                                                                      NSNumber(value: result3),
                                                                                                      NSNumber(value: result4)
                                                                                                     ]), nReadData: 14)
    }
    
    
    /**
     * Return the Latitude value
     * @param sample data sample
     * @return
     */
    public func getLatitudeValue(sample: BlueSTSDKFeatureSample?) -> Float? {
        if !(sample == nil)  {
            if !(sample!.data.isEmpty){
                if !(sample!.data[0] == nil){
                    return Float(Float(sample!.data[0]) / 1e+07)
                }
            }
        }
        return nil
    }
    
    /**
     * Return the Longitude value
     * @param sample data sample
     * @return
     */
    public func getLongitudeValue(sample: BlueSTSDKFeatureSample?) -> Float? {
        if !(sample == nil)  {
            if !(sample!.data.isEmpty){
                if !(sample!.data[1] == nil){
                    return Float(Float(sample!.data[1]) / 1e+07)
                }
            }
        }
        return nil
    }
    
    /**
     * Return the Altitude value
     * @param sample data sample
     * @return
     */
    public func getAltitudeValue(sample: BlueSTSDKFeatureSample?) -> Float? {
        if !(sample == nil)  {
            if !(sample!.data.isEmpty){
                if !(sample!.data[2] == nil){
                    return Float(Float(sample!.data[2]) / 1e+03)
                }
            }
        }
        return nil
    }
    
    /**
     * Return the Satellites Number value
     * @param sample data sample
     * @return
     */
    public func getNSatValue(sample: BlueSTSDKFeatureSample?) -> Int? {
        if !(sample == nil) {
            if !(sample!.data.isEmpty){
                if !(sample!.data[3] == nil){
                    return convertByteToInt(b: UInt8(sample!.data[3]))
                }
            }
        }
        return nil
    }
    
    /**
     * Return the Signal quality value
     * @param sample data sample
     * @return
     */
    public func getSigQualityValue(sample: BlueSTSDKFeatureSample?) -> Int? {
        if !(sample == nil)  {
            if !(sample!.data.isEmpty){
                if !(sample!.data[4] == nil){
                    return convertByteToInt(b: UInt8(sample!.data[4]))
                }
            }
        }
        return nil
    }
    
    private func convertByteToInt(b: UInt8) -> Int {
        if(b<0){
            return 255 + Int(b) + 1
        }else{
            return Int(b)
        }
    }
    
}
