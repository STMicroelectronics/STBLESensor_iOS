//
//  BlueSTSDKFeatureNEAIAnomalyDetection.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class BlueSTSDKFeatureNEAIAnomalyDetection : BlueSTSDKFeature {
    private static let FEATURE_NAME = "NEAI AD";
    
    private static let stopCommand: UInt8 = 0x00
    private static let learningCommand: UInt8 = 0x01
    private static let detectionCommand: UInt8 = 0x02
    private static let resetKnowledgeCommand: UInt8 = 0xFF
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "Phase", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:2)),
        BlueSTSDKFeatureField(name: "State", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value: 127)),
        BlueSTSDKFeatureField(name: "Phase Progress", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value: 100)),
        BlueSTSDKFeatureField(name: "Status", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value: 1)),
        BlueSTSDKFeatureField(name: "Similarity", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value: 100))
    ];
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureNEAIAnomalyDetection.FIELDS;
    }
    
    public enum PhaseType : UInt8{
        public typealias RawValue = UInt8
        /** idle */
        case IDLE = 0x0
        /** learning */
        case LEARNING = 0x01
        /** detection */
        case DETECTION = 0x02
        /** detection */
        case IDLE_TRAINED = 0x03
        /** busy */
        case BUSY = 0x04
        /** null */
        case NULL = 0xFF
    }
    
    public enum StateType : UInt8{
        public typealias RawValue = UInt8
        /** ok */
        case OK = 0x0
        /** initFctNotCalled */
        case INIT_NOT_CALLED = 0x7B
        /** boardError */
        case BOARD_ERROR = 0x7C
        /** knowledgeBufferError */
        case KNOWLEDGE_ERROR = 0x7D
        /** notEnoughCallToLearning */
        case NOT_ENOUGH_LEARNING = 0x7E
        /** notEnoughCallToLearning */
        case MINIMAL_LEARNING_DONE = 0x7F
        /** unknownError */
        case UNKOWN_ERROR = 0x80
        /** null */
        case NULL = 0xFF
    }
    
    public enum StatusType : UInt8{
        public typealias RawValue = UInt8
        /** normal */
        case NORMAL = 0x0
        /** anomaly */
        case ANOMALY = 0x01
        /** null */
        case NULL = 0xFF
    }
    
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureNEAIAnomalyDetection.FEATURE_NAME)
    }
    
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        
        let intOffset = Int(offset)
        
        let phase = (data as NSData).extractUInt8(fromOffset: UInt(4))
        let state = (data as NSData).extractUInt8(fromOffset: UInt(5))
        let phaseProgress = (data as NSData).extractUInt8(fromOffset: UInt(6))
        let status = (data as NSData).extractUInt8(fromOffset: UInt(7))
        let similarity = (data as NSData).extractUInt8(fromOffset: UInt(8))

        return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: [NSNumber(value: phase),
                                                                                                      NSNumber(value: state),
                                                                                                      NSNumber(value: phaseProgress),
                                                                                                      NSNumber(value: status),
                                                                                                      NSNumber(value: similarity)
                                                                                                     ]), nReadData: 9)
    }
    
    
    /**
     * Return the Phase value
     * @param sample data sample
     * @return
     */
    public func getPhaseValue(sample: BlueSTSDKFeatureSample) -> PhaseType {
        guard sample.data.count > 0 else {
            return PhaseType.NULL
        }
        let rawValue = sample.data[0].uint8Value
        return PhaseType.init(rawValue: rawValue) ?? PhaseType.NULL
    }
    
    /**
     * Return the State value
     * @param sample data sample
     * @return
     */
    public func getStateValue(sample: BlueSTSDKFeatureSample) -> StateType {
        guard sample.data.count > 0 else {
            return StateType.NULL
        }
        let rawValue = sample.data[1].uint8Value
        return StateType.init(rawValue: rawValue) ?? StateType.NULL
    }
    
    /**
     * Return the Phase Progress value
     * @param sample data sample
     * @return
     */
    public func getPhaseProgressValue(sample: BlueSTSDKFeatureSample) -> Int {
        guard sample.data.count > 0 else {
            return 0
        }
        let rawValue = sample.data[2].uint8Value
        return Int(rawValue) ?? 0
    }
    
    /**
     * Return the Status value
     * @param sample data sample
     * @return
     */
    public func getStatusValue(sample: BlueSTSDKFeatureSample) -> StatusType {
        guard sample.data.count > 0 else {
            return StatusType.NULL
        }
        let rawValue = sample.data[3].uint8Value
        return StatusType.init(rawValue: rawValue) ?? StatusType.NULL
    }
    
    /**
     * Return the Similarity value
     * @param sample data sample
     * @return
     */
    public func getSimilarityValue(sample: BlueSTSDKFeatureSample) -> Int {
        guard sample.data.count > 0 else {
            return 0
        }
        let rawValue = sample.data[4].uint8Value
        return Int(rawValue) ?? 0
    }
    
    public func writeStopCommand(f: BlueSTSDKFeature){
        f.parentNode.writeData(to: f, data: Data([BlueSTSDKFeatureNEAIAnomalyDetection.stopCommand]))
        
    }
    
    public func writeLearningCommand(f: BlueSTSDKFeature){
        f.parentNode.writeData(to: f, data: Data([BlueSTSDKFeatureNEAIAnomalyDetection.learningCommand]))
    }
    
    public func writeDetectionCommand(f: BlueSTSDKFeature){
        f.parentNode.writeData(to: f, data: Data([BlueSTSDKFeatureNEAIAnomalyDetection.detectionCommand]))
    }
    
    public func writeResetKnowledgeCommand(f: BlueSTSDKFeature){
        f.parentNode.writeData(to: f, data: Data([BlueSTSDKFeatureNEAIAnomalyDetection.resetKnowledgeCommand]))
    }
}
