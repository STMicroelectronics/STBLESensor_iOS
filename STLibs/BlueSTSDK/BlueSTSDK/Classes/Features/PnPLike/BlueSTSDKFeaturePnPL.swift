//
//  BlueSTSDKFeaturePnPL.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class BlueSTSDKFeaturePnPL : BlueSTSDKFeature {
    private static let FEATURE_NAME = "PnPLike";
    
    private var commandManager: WriteDataManager?
    private let dataTransporter = DataTransporter()
    
    private var pnpLikeDtmiCommands: PnPLikeDtmiCommands?
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: FEATURE_NAME, unit: nil, type: .uInt8Array, min: NSNumber(value: Int8.min), max: NSNumber(value: Int8.max))
    ];
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeaturePnPL.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeaturePnPL.FEATURE_NAME)
        self.commandManager = WriteDataManager(feature: self)
    }
    
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        
        guard let commandFrame = dataTransporter.decapsulate(data: data) else {
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        /** OLD FLOW
        /// 1. Decode Board Response
        let response = PnPLikeService.responseFrom(data: commandFrame)
        
        /// 2. Check if dtmi components are present in json of board components and extract schemas
        let schemas = PnPLikeService.extractDtmiSchemaComponents(pnpLikeDtmiCommands: pnpLikeDtmiCommands, pnpLikeBoardResponse: response)
        
        /// 3. Filter dtmi components for only necessary elements
        let components = PnPLikeService.filterPnPLikeDtmiCommands(pnpLikeDtmiCommands: pnpLikeDtmiCommands, schemas: schemas)
        
        /// 4. Extract Actual Board Configuration
        let config = PnPLikeService.buildPnPLConfiguration(pnpLikeDtmiCommands: pnpLikeDtmiCommands, pnpLikeBoardResponse: response)
        
        return BlueSTSDKExtractResult(whitSample:
                                        PnPLSample(
                                            pnplBoardResponse: response,
                                            pnplDtmiFiltered: components,
                                            pnpLConfiguration: config
                                        ),
                                      nReadData: UInt32(data.count))
         */
        
        /// 1. Decode Board Response
        let response = PnPLikeService.responseFrom(data: commandFrame)
        
        /// 2. Extract Actual Board Configuration
        let config = PnPLikeService.buildPnPLConfiguration(pnpLikeDtmiCommands: pnpLikeDtmiCommands, pnpLikeBoardResponse: response)
        
        return BlueSTSDKExtractResult(whitSample: PnPLSample(pnpLConfiguration: config), nReadData: UInt32(data.count))
    }
    
    public func sendCommand(_ command: String?, completion: @escaping () -> Void) {
        sendWrite(dataTransporter.encapsulate(string: command), completion: completion)
    }
    
    private func sendWrite(_ data: Data, completion: @escaping () -> Void) {
        commandManager?.enqueueCommand(WriteDataManager.WriteData(data: data, completion: { _ in
            completion()
        }))
    }
    
    /**
     Function called in EnableNotification:
        - Save dtmi obj (PnPLikeCommands)
        - Send to board {get_status: all} json
        - Handle board response
     */
    public func sendPnPLGetDeviceStatusCmd(dtmi: PnPLikeDtmiCommands?) {
        pnpLikeDtmiCommands = dtmi
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue("all", forKey: "get_status")
        let jsonData: NSData
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            sendCommand(jsonString) {}
        } catch _ {
            print ("JSON Failure")
        }
    }
    
    public func sendPnPLJSON(elementName: String?, paramName: String?, objectName: String?, value: Any) {
        guard let elementName = elementName else { return }
        guard let paramName = paramName else { return }

        var objectNameValue: NSMutableDictionary = NSMutableDictionary()
        var paramNameValue: NSMutableDictionary = NSMutableDictionary()
        var elementNameValue: NSMutableDictionary = NSMutableDictionary()
        
        if(objectName != nil){
            objectNameValue.setValue(value, forKey: objectName!)
            paramNameValue.setValue(objectNameValue, forKey: paramName)
            elementNameValue.setValue(paramNameValue, forKey: elementName)
        } else {
            paramNameValue.setValue(value, forKey: paramName)
            elementNameValue.setValue(paramNameValue, forKey: elementName)
        }
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: elementNameValue, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            sendCommand(jsonString) {}
            print(jsonString)
        } catch _ {
            print ("JSON Failure")
        }
        
    }
    
    public func sendPnPLCommandJSON(elementName: String?, paramName: String?, requestName: String?, objectName: String?, value: Any?) {
        guard let elementName = elementName else { return }
        guard let paramName = paramName else { return }

        var objectNameValue: NSMutableDictionary = NSMutableDictionary()
        var requestParamNameValue: NSMutableDictionary = NSMutableDictionary()
        var elementParamNameValue: NSMutableDictionary = NSMutableDictionary()
        
        if(requestName != nil) { /// Command with only request.name
            requestParamNameValue.setValue(value, forKey: requestName!)
            elementParamNameValue.setValue(requestParamNameValue, forKey: "\(elementName)*\(paramName)")
        } else { /// Empty command
            objectNameValue.setValue(nil, forKey: "")
            elementParamNameValue.setValue(objectNameValue, forKey: "\(elementName)*\(paramName)")
        }
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: elementParamNameValue, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            sendCommand(jsonString) {}
            print(jsonString)
        } catch _ {
            print ("JSON Failure")
        }
        
    }
    
    public func sendPnPLCommandObjectJSON(elementName: String?, paramName: String?, requestName: String?, objectsName: [String]?, values: [Any]?) {
        guard let elementName = elementName else { return }
        guard let paramName = paramName else { return }
        guard let requestName = requestName else { return }
        guard let objectsName = objectsName else { return }
        guard let values = values else { return }

        guard objectsName.count > 0 else { return }
        guard values.count > 0 else { return }
        
        var objectNameValue: NSMutableDictionary = NSMutableDictionary()
        var requestParamNameValue: NSMutableDictionary = NSMutableDictionary()
        var elementParamNameValue: NSMutableDictionary = NSMutableDictionary()
        
        for i in 0...(objectsName.count) - 1{
            objectNameValue.setValue(values[i], forKey: objectsName[i])
        }
        
        requestParamNameValue.setValue(objectNameValue, forKey: requestName)
        elementParamNameValue.setValue(requestParamNameValue, forKey: "\(elementName)*\(paramName)")

        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: elementParamNameValue, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            sendCommand(jsonString) {}
            print(jsonString)
        } catch _ {
            print ("JSON Failure")
        }
        
    }
    
}

public class PnPLSample: BlueSTSDKFeatureSample {
    public let pnpLConfiguration: [PnPLConfiguration]?

    public init(pnpLConfiguration: [PnPLConfiguration]?) {
        self.pnpLConfiguration = pnpLConfiguration
        super.init(whitData: [])
    }
}

/** OLD PnPLSample ---
public class PnPLSample: BlueSTSDKFeatureSample {
    public let pnplBoardResponse: PnPLikeDataModelResponse?
    public let pnplDtmiFiltered: PnPLikeDtmiCommands?
    public let pnpLConfiguration: [PnPLConfiguration]?
    
    public init(pnplBoardResponse: PnPLikeDataModelResponse?, pnplDtmiFiltered: PnPLikeDtmiCommands?, pnpLConfiguration: [PnPLConfiguration]?) {
        self.pnplBoardResponse = pnplBoardResponse
        self.pnplDtmiFiltered = pnplDtmiFiltered
        self.pnpLConfiguration = pnpLConfiguration
        
        super.init(whitData: [])
    }
}
*/
