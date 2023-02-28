//
//  BlueSTSDKFeatureNEAInClassification.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class BlueSTSDKFeatureNEAIClassification : BlueSTSDKFeature {
    private static let FEATURE_NAME = "NEAI Classification";
    
    private static let stopCommand: UInt8 = 0x00
    private static let startClassification: UInt8 = 0x01
    
    private static let N_MAX_CLASS_NUMBER = 8
    public static let CLASS_PROB_ESCAPE_CODE: UInt8 = 0xFF
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "Mode", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:2)),
        BlueSTSDKFeatureField(name: "Phase", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value: 1)),
        BlueSTSDKFeatureField(name: "State", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value: 128)),
        BlueSTSDKFeatureField(name: "Class Major Prob", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value: 8)),
        BlueSTSDKFeatureField(name: "ClassesNumber", unit: nil, type: .uInt8,
                              min: NSNumber(value: 2),
                              max: NSNumber(value: 8)),
        BlueSTSDKFeatureField(name: "Class 1 Probability", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:100)),
        BlueSTSDKFeatureField(name: "Class 2 Probability", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:100)),
        BlueSTSDKFeatureField(name: "Class 3 Probability", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:100)),
        BlueSTSDKFeatureField(name: "Class 4 Probability", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:100)),
        BlueSTSDKFeatureField(name: "Class 5 Probability", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:100)),
        BlueSTSDKFeatureField(name: "Class 6 Probability", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:100)),
        BlueSTSDKFeatureField(name: "Class 7 Probability", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:100)),
        BlueSTSDKFeatureField(name: "Class 8 Probability", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:100)),
    ];
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureNEAIClassification.FIELDS;
    }
    
    public enum PhaseType : UInt8{
        public typealias RawValue = UInt8
        /** idle */
        case IDLE = 0x0
        /** classification */
        case CLASSIFICATION = 0x01
        /** busy */
        case BUSY = 0x02
        /** null */
        case NULL = 0xFF
    }
    
    public enum ModeType : UInt8{
        public typealias RawValue = UInt8
        /** 1 class */
        case ONE_CLASS = 0x01
        /** n class */
        case N_CLASS = 0x02
        /** null */
        case NULL = 0xFF
    }
    
    public enum StateType : UInt8{
        public typealias RawValue = UInt8
        /** ok */
        case OK = 0x0
        /** init not called */
        case INIT_NOT_CALLED = 0x7B
        /** board error */
        case BOARD_ERROR = 0x7C
        /** ok */
        case KNOWLEDGE_ERROR = 0x7D
        /** init not called */
        case NOT_ENOUGH_LEARNING = 0x7E
        /** board error */
        case MINIMAL_LEARNING_DONE = 0x7F
        /** init not called */
        case UNKNOWN_ERROR = 0x80
        /** board error */
        case NULL = 0xFF
    }
    
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureNEAIClassification.FEATURE_NAME)
    }
    
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        
        let intOffset = Int(offset)
        
        if ((data.count - intOffset) < 4) {
            NSException(
                name: NSExceptionName(rawValue: "Invalid data "),
                reason: "There are no enough bytes (4) available to read",
                userInfo: nil
            ).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        } else {
            if ((data.count - intOffset)==4) {
                // We are in Idle Phase
                var results: [UInt8] = [0,0]
                // Mode 1-Class / N-Class
                results[0] = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2))
                // Phase
                results[1] = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 1))
                return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: [NSNumber(value: results[0]),
                                                                                                             NSNumber(value: results[1])]), nReadData: 2+2)
            } else {
                let mode = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2))
                
                switch mode {
                case 0x01: /// 1-Class
                    if ((data.count-intOffset) != 6){
                        NSException(
                            name: NSExceptionName(rawValue: "Invalid data"),
                            reason: "Wrong number of bytes \(data.count-intOffset) for 1-Class",
                            userInfo: nil
                        ).raise()
                        return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
                    }
                    
                    let phase = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 1))
                    let state = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 2))
                    let classMajor = UInt(1)
                    let classNumber = UInt(1)
                    let class1Outlier = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 3))
                    return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: [NSNumber(value: mode),
                                                                                                                  NSNumber(value: phase),
                                                                                                                  NSNumber(value: state),
                                                                                                                  NSNumber(value: classMajor),
                                                                                                                  NSNumber(value: classNumber),
                                                                                                                  NSNumber(value: class1Outlier)
                                                                                                                 ]), nReadData: 2+4)
                case 0x02: /// N-Class
                    if ((data.count-intOffset) == 6){
                        let phase = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 1))
                        let state = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 2))
                        let classMajor = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 3))
                        if(classMajor != 0) {
                            NSException(
                                name: NSExceptionName(rawValue: "Invalid data"),
                                reason: "Unknown case not valid \(classMajor) != 0",
                                userInfo: nil
                            ).raise()
                            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
                        }
                        let classNumber = UInt(1)
                        return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: [NSNumber(value: mode),
                                                                                                                      NSNumber(value: phase),
                                                                                                                      NSNumber(value: state),
                                                                                                                      NSNumber(value: classMajor),
                                                                                                                      NSNumber(value: classNumber)
                                                                                                                     ]), nReadData: 2+4)
                    } else {
                        let numClasses = data.count - intOffset - 6
                        if(numClasses > BlueSTSDKFeatureNEAIClassification.N_MAX_CLASS_NUMBER) {
                            NSException(
                                name: NSExceptionName(rawValue: "Invalid data"),
                                reason: "Too many classes \(numClasses)",
                                userInfo: nil
                            ).raise()
                            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
                        }
                        
                        let phase = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 1))
                        let state = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 2))
                        let classMajor = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 3))
                        
                        var results: [NSNumber] = []
                        results.append(NSNumber(value: mode))
                        results.append(NSNumber(value: phase))
                        results.append(NSNumber(value: state))
                        results.append(NSNumber(value: classMajor))
                        results.append(NSNumber(value: numClasses))
                        
                        for index in 0...numClasses - 1 {
                            let val = (data as NSData).extractUInt8(fromOffset: UInt(intOffset + 2 + 4 + index))
                            results.append(NSNumber(value: val))
                        }
                        let sample = BlueSTSDKFeatureSample(timestamp: timestamp, data: results)
                        let nReadData = 2+4+numClasses
                        return BlueSTSDKExtractResult(whitSample: sample, nReadData: UInt32(nReadData))
                    }

                default:
                    NSException(
                        name: NSExceptionName(rawValue: "Invalid data"),
                        reason: "Mode Type not recognized",
                        userInfo: nil
                    ).raise()
                    return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
                }
            }
        }
        return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
    }
    
    /**
     * Return the Mode value
     * @param sample data sample
     * @return
     */
    public func getModeValue(sample: BlueSTSDKFeatureSample) -> ModeType {
        guard sample.data.count > 0 else {
            return ModeType.NULL
        }
        let rawValue = sample.data[0].uint8Value
        return ModeType.init(rawValue: rawValue) ?? ModeType.NULL
    }
    
    /**
     * Return the Phase value
     * @param sample data sample
     * @return
     */
    public func getPhaseValue(sample: BlueSTSDKFeatureSample) -> PhaseType {
        guard sample.data.count > 1 else {
            return PhaseType.NULL
        }
        let rawValue = sample.data[1].uint8Value
        return PhaseType.init(rawValue: rawValue) ?? PhaseType.NULL
    }
    
    /**
     * Return the State value
     * @param sample data sample
     * @return
     */
    public func getStateValue(sample: BlueSTSDKFeatureSample) -> StateType {
        guard sample.data.count > 2 else {
            return StateType.NULL
        }
        let rawValue = sample.data[2].uint8Value
        return StateType.init(rawValue: rawValue) ?? StateType.NULL
    }
    
    /**
     * Return the Most Probable value class
     * @param sample data sample
     * @return
     */
    public func getMostProbableClass(sample: BlueSTSDKFeatureSample) -> Int {
        guard sample.data.count > 3 else {
            return 0
        }
        let rawValue = sample.data[3].uint8Value
        return Int(rawValue) ?? 0
    }
    
    /**
     * Return the Classes Number from a NEAI (nClass) message
     * @param sample data sample
     * @return
     */
    public func getClassNumber(sample: BlueSTSDKFeatureSample) -> Int {
        guard sample.data.count > 4 else {
            return 0
        }
        let rawValue = sample.data[4].uint8Value
        return Int(rawValue) ?? 0
    }
    
    /**
     * Return the Probability value
     * @param sample data sample
     * @return
     */
    public func getClassProbability(sample: BlueSTSDKFeatureSample, num: Int) -> Int {
        guard sample.data.count > 5 else {
            return 0
        }
        let rawValue = sample.data[num + 5].uint8Value
        return Int(rawValue) ?? 0
    }
    
    public func writeStopClassificationCommand(f: BlueSTSDKFeature){
        f.parentNode.writeData(to: f, data: Data([BlueSTSDKFeatureNEAIClassification.stopCommand]))
    }
    
    public func writeStartClassificationCommand(f: BlueSTSDKFeature){
        f.parentNode.writeData(to: f, data: Data([BlueSTSDKFeatureNEAIClassification.startClassification]))
    }
    
}
