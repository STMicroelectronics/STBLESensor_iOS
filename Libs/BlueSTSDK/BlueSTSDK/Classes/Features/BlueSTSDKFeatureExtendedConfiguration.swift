//
//  BlueSTSDKFeatureExtendedConfiguration.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 27/04/21.
//

import Foundation

public class BlueSTSDKFeatureExtendedConfiguration: BlueSTSDKFeature {
    public static let FEATURE_NAME = "ExtConfig"
    
    private static let FEATURE_DATA_NAME = "Configuration"
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: FEATURE_DATA_NAME, unit: nil, type: .uInt8Array, min: NSNumber(value: Int8.min), max: NSNumber(value: Int8.max))
    ]
    
    public var debug: Bool = false {
        didSet {
            commandManager?.debug = debug
        }
    }
    
    private let dataTransporter = DataTransporter()
    private var commandManager: WriteDataManager?
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureExtendedConfiguration.FEATURE_NAME)
        self.commandManager = WriteDataManager(feature: self)
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        if var commandFrame = dataTransporter.decapsulate(data: data) {
            if debug {
                debugPrint("Extract Data: \(String(data: commandFrame, encoding: .utf8))")
            }
            
            do {
                commandFrame.removeLast()
                let response = try JSONDecoder().decode(ECResponse.self, from: commandFrame)
                return BlueSTSDKExtractResult(whitSample: ECFeatureSample(response: response), nReadData: 0)
            } catch {
                debugPrint("Extract Data parse error: \(error)")
            }
        }
        
        return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
    }
    
    public func sendCommand(_ type: ECCommandType) {
        let command = ECCommand<String>(type: type)
        sendCommand(command)
    }
    
    public func sendCommand(_ type: ECCommandType, string: String) {
        let command = ECCommand<String>(type: type, argString: string)
        sendCommand(command)
    }
    
    public func sendCommand(_ type: ECCommandType, int: Int) {
        let command = ECCommand<String>(type: type, argNumber: int)
        sendCommand(command)
    }
    
    public func sendCommand<T: Encodable>(_ type: ECCommandType, json: T) {
        let command = ECCommand(type: type, argJSON: json)
        sendCommand(command)
    }
    
    public func sendCommand(_ commandName: String) {
        let command = ECCommand<String>(name: commandName)
        sendCommand(command)
    }
    
    public func sendCommand(_ commandName: String, string: String) {
        let command = ECCommand<String>(name: commandName, argString: string)
        sendCommand(command)
    }
    
    public func sendCommand(_ commandName: String, int: Int) {
        let command = ECCommand<Int>(name: commandName, argNumber: int)
        sendCommand(command)
    }
    
    public func sendHSDCommand(_ hsdCommand: HSDSetCmd, _ completion: @escaping () -> Void) {
        let command = ECCommand<String>(type: .setSensorsConfig)
        guard let json = command.jsonWithHSDSetCommand(hsdCommand) else { return }
        
        sendJSONCommand(json, completion)
    }
    
    private func sendCommand<T: Encodable>(_ command: ECCommand<T>) {
        guard let json = command.json else { return }
        
        sendJSONCommand(json) {}
    }
    
    private func sendJSONCommand(_ json: String, _ completion: @escaping () -> Void) {
        if debug { debugPrint("Send command: \(json)") }
        
        sendWrite(dataTransporter.encapsulate(string: json), completion: completion)
    }
    
    private func sendWrite(_ data: Data, completion: @escaping () -> Void) {
        commandManager?.enqueueCommand(WriteDataManager.WriteData(data: data, completion: { _ in
            completion()
        }))
    }
}
