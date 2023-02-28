//
//  PnPLikeService.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum PnPLDtmiType {
    case standard
    case custom
}

public class PnPLikeService {
    
    private static let pnplKey = "BlueSTPnPLKey"
    private static let custompnplKey = "BlueSTPnPLKey"
    
    private static let demoKey = "BlueSTPnPCurrentDemoKey"
    
    public init() {
        Self.self
    }
    
    public func currentPnPLDtmi() -> PnPLikeDtmiCommands? {
        let userDefaults = UserDefaults.standard
        
        let storedPnPLDtmi = userDefaults.object(forKey: PnPLikeService.custompnplKey) ?? userDefaults.object(forKey: PnPLikeService.pnplKey)
        
        if let storedPnPLDtmi = storedPnPLDtmi as? Data {
            let decoder = JSONDecoder()
            if let loadedPnPLDtmi = try? decoder.decode(PnPLikeDtmiCommands.self, from: storedPnPLDtmi) {
                return loadedPnPLDtmi
            }
        }
        
        return nil
    }
    
    @discardableResult
    public func storePnPLDtmi(_ pnplDtmi: PnPLikeDtmiCommands?, type: PnPLDtmiType) -> PnPLikeDtmiCommands? {
        let userDefaults = UserDefaults.standard
        
        let pnplDtmiKey = type == .standard ? PnPLikeService.pnplKey : PnPLikeService.custompnplKey
        
        guard let pnplDtmi = pnplDtmi else {
            userDefaults.removeObject(forKey: pnplDtmiKey)
            userDefaults.synchronize()
            return pnplDtmi
        }
    
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(pnplDtmi) {
            userDefaults.set(encoded, forKey: pnplDtmiKey)
            userDefaults.synchronize()
            return pnplDtmi
        }
        
        return nil
    }
    
    /// Used to PnPL Demo Customization
    public func getPnPLCurrentDemo() -> String? {
        let userDefaults = UserDefaults.standard
        let storedPnPLDtmi = userDefaults.object(forKey: PnPLikeService.demoKey)
        return userDefaults.string(forKey: PnPLikeService.demoKey)
    }
    
    @discardableResult
    public func storePnPLCurrentDemo(_ currentDemo: String?) {
        let userDefaults = UserDefaults.standard
        let storedPnPLDtmi = userDefaults.object(forKey: PnPLikeService.demoKey)
        userDefaults.set(currentDemo, forKey: PnPLikeService.demoKey)
    }
    
    ///TODO: dtmi download
    
    static func responseFrom(data: Data) -> PnPLikeDataModelResponse? {
        var finalData = data
        finalData.removeLast()
        let string = String(data: finalData, encoding: .utf8)
        do {
            return try JSONDecoder().decode(PnPLikeDataModelResponse.self, from: finalData)
        } catch {
            return nil
        }
    }
    
    // MARK: - Nested Funtions
    
    /// Function used to search for dtmi components in the corresponding json received by the device
    public static func searchKey(keyvalue: String?, object: JSONValue?) -> JSONValue? {
        if(keyvalue != nil && object != nil){
            
            switch object {
         
            case .object(let dict):
                for key in dict.keys {
                    if keyvalue == key{
                        return dict[key]
                    } else {
                        return searchKey(keyvalue: key, object: dict[key]!)
                    }
                }

            case .array(let arr):
                for item in arr {
                    if let foundObj = searchKey(keyvalue: keyvalue, object: item){ return foundObj }
                }
                return nil
                
            default:
                return nil
            }
            
        }
        
        return nil
        
    }
    
    /**
     
    static func searchKeyInArray(keyvalue: String, objects: [JSONValue]) -> JSONValue? {
        
        for object in objects {
            if let foundObj = searchKey(keyvalue: keyvalue, object: object){ return foundObj }
        }
        return nil
    }
    */
    
    /// Function used to search to extract JSON OBJECT parameters in Json Baord
    public static func extractObjectParam(keyvalue: String?, object: JSONValue?) -> JSONValue? {
        if(keyvalue != nil && object != nil){
            switch object {
            case .object(let dict):
                for key in dict.keys {
                    if(keyvalue==key){
                        return dict[key]!
                    }
                }
            default:
                return nil
            }
        }
        return nil
    }
    
    /// Function used to search to extract actual value for a specific parameter present in JSON Board
    public static func extractValueParam(keyvalue: String?, object: JSONValue?) -> Any? {
        if(keyvalue != nil && object != nil){
            
            switch object {
                
            case .object(let dict):
                for key in dict.keys {
                    if(keyvalue==key){
                        return extractValue(object: dict[key]!)
                    }
                }
                
            default:
                return nil
            }
            
        }
        
        return nil
        
        
    }
    
    public static func extractValue(object: JSONValue?) -> Any? {
        if(object != nil){
            
            switch object {
         
            case .int(let int):
                return int
            case .double(let double):
                return double
            case .bool(let bool):
                return bool
            case .string(let str):
                return str
                
            default:
                return nil
            }
            
        }
        
        return nil
        
        
    }
    
    
    /// Function used to search if dtmi components is present in the corresponding json received by the device
    static func checkIfComponentIsPresent(keyvalue: String?, object: JSONValue?) -> Bool {
        if(keyvalue != nil && object != nil){
            
            switch object {
         
            case .object(let dict):
                for key in dict.keys {
                    if keyvalue == key{
                        return true
                    } else {
                        return false
                    }
                }

            case .array(let arr):
                for item in arr {
                    if let foundObj = searchKey(keyvalue: keyvalue, object: item){ return true }
                }
                return false
                
            default:
                return false
            }
            
        }
        
        return false
        
    }
    
    /// Extract DTMI Schema URL String
    static func extractSchemaUrl(schema: SchemaContent?) -> String? {
        switch schema {
     
        case .string(let url):
            return url

        case .schemaObject(let obj):
            return nil
            
        default:
            return nil
        }
        
    }
    
    /// Extract DTMI String Array Type
    static func extractTypeStringArray(schema: TypeContent?) -> [String]? {
        switch schema {
     
        case .string(let str):
            return nil

        case .stringArray(let arr):
            return arr
            
        default:
            return nil
        }
        
    }
    
    /// Extract DTMI String Type
    static func extractTypeString(schema: TypeContent?) -> String? {
        switch schema {
     
        case .string(let str):
            return str
            
        default:
            return nil
        }
        
    }
    
    /// Extract DTMI Object Schema
    static func extractSchemaObject(schema: SchemaContent?) -> SchemaObject? {
        switch schema {
     
        case .string(let url):
            return nil

        case .schemaObject(let obj):
            return obj
            
        default:
            return nil
        }
        
    }
    
    /// Extract DTMI Schema String (integer, double, boolean, etc ...)
    static func extractSchemaString(schema: SchemaContent?) -> String? {
        switch schema {
     
        case .string(let str):
            return str
            
        default:
            return nil
        }
        
    }
        

    // MARK: -Function used to search for dtmi contents and extract component name
    static func extractDtmiSchemaComponents(pnpLikeDtmiCommands: PnPLikeDtmiCommands?, pnpLikeBoardResponse: PnPLikeDataModelResponse?) -> [String] {
        var schemas: [String] = []
        
        pnpLikeDtmiCommands?[0].contents.forEach{ content in
            pnpLikeBoardResponse?.devices.forEach{ device in
                if(checkIfComponentIsPresent(keyvalue: content.name, object: device.components)){
                    guard let s = extractSchemaUrl(schema: content.schema) else{ return }
                    schemas.append(s)
                    //componentsNameAndSchema.updateValue(content.schema.debugDescription, forKey: content.name ?? "--")
                }
            }
        }
        return schemas
    }
    
    /* MARK: -Function used to filter only necessary components - Matching Board - Remote DTMI
    static func filterPnPLikeDtmiCommands(pnpLikeDtmiCommands: PnPLikeDtmiCommands?, schemas: [String]) -> PnPLikeDtmiCommands {
        var elements: [PnPLikeElement] = []
        
        pnpLikeDtmiCommands?.forEach{ element in
            schemas.forEach{ schema in
                if(element.id == schema){
                    elements.append(element)
                }
            }
        }
        return elements
     }*/

    // MARK: -Function used to filter only THE FIRST ELEMENT
        static func filterFirstPnPLikeDtmiCommands(pnpLikeDtmiCommands: PnPLikeDtmiCommands?, schemas: [String]) -> PnPLikeDtmiCommands {
            var elements: [PnPLikeElement] = []
            var i = 0
            pnpLikeDtmiCommands?.forEach{ element in
                if(i==0) { i+=1 } else {
                    elements.append(element)
                    i+=1
                }
            }
            return elements
        }
    
    // MARK: - Function used to BUILD configuration structure ---> used to draw the UI
    public static func buildPnPLConfiguration(pnpLikeDtmiCommands: PnPLikeDtmiCommands?, pnpLikeBoardResponse: PnPLikeDataModelResponse?) -> [PnPLConfiguration] {
        
        var configurations: [PnPLConfiguration] = []
        
        pnpLikeDtmiCommands?[0].contents.forEach{ content in
            
            /// Obtained BOARD JSON sensor configuration
            let boardSensorConfiguration = searchKey(keyvalue: content.name, object: pnpLikeBoardResponse?.devices[0].components)
            
            /// Check and Match Single Sensor Parameter / Component (PnPLike Element) between DTMI and BOARD jsons
            /// --- Extract and return PnPLike Element retrieved from DTMI ---
            let element = findPnPLElement(schema: extractSchemaUrl(schema: content.schema), pnpLikeDtmiCommands: pnpLikeDtmiCommands)
            
            var parameters: [PnPLConfigurationParameter] = []
        
            let type = extractPnPLType(sensorName: content.name)
            
            /// Fill parameters name-value for a specific sensor
            element?.contents.forEach{ param in
                
                let paramTypeAndDetail = buildParameterType(param: param, boardSensorConfiguration: boardSensorConfiguration)

                let p = PnPLConfigurationParameter(
                    name: param.name,
                    displayName: param.displayName.en,
                    type: paramTypeAndDetail.0,
                    detail: paramTypeAndDetail.1,
                    unit: param.unit,
                    writable: param.writable)
                
                parameters.append(p)
            }
                
            configurations.append(
                PnPLConfiguration(
                    name: content.name,
                    specificSensorOrGeneralType: type,
                    displayName:content.displayName.en,
                    parameters: parameters,
                    visibile: false
                )
            )
        }
        
        return configurations
    }
    
    // MARK: - Function used to Match Schema url in Element[0].contents[i] with @id in Element[i]
    static func findPnPLElement(schema: String?, pnpLikeDtmiCommands: PnPLikeDtmiCommands?) -> PnPLikeElement? {
        if(pnpLikeDtmiCommands != nil){
            for element in pnpLikeDtmiCommands! {
                if(element.id == schema){
                    return element
                }
            }
        }
        return nil
    }
    
    // MARK: - Function used to build up Enum Values declared in DTMI
    static func extractEnumValues(paramType: ParameterType, param: PnPLikeContent) -> [Int: String]? {
        //let schema = extractSchemaObject(schema: sensor.schema)
        var schema: SchemaObject? = nil
        
        if(paramType == .PropertyEnumeration){
            schema = extractSchemaObject(schema: param.schema)
        } else {
            schema = extractSchemaObject(schema: param.request?.schema)
        }
        
        var tuples: [Int: String] = [:]
        schema?.enumValues?.forEach{ enumValue in
            if(enumValue.enumValue != nil){
                tuples[enumValue.enumValue!] = enumValue.displayName.en
            }
        }
        
        return tuples
    }

    // MARK: - Function used to extract typo from DTMI
    static func extractPnPLType(sensorName: String) -> PnPLType {
        if(sensorName.contains("_")){
            let components = sensorName.components(separatedBy: "_")
            let type = PnPLType(rawValue: components[1])
            return type ?? .Unknown
        }else {
            return PnPLType.Unknown
        }
    }
    
    // MARK: - Function used to build complex PARAMETER (ex. object structure inside a Parameter Object)
    static func buildParameterObject(paramType: ParameterType, param: PnPLikeContent, boardSensorConfiguration: JSONValue?) -> [ObjectNameValue]? {
        var paramObj: PnPLConfigurationParameter? = nil
        
        /// Used for correct selection
        var currentParameterObject: [EnumResponseValue]? = []
        if(paramType == .PropertyObject){
            currentParameterObject = isParameterObject(schema: param.schema)
        } else {
            currentParameterObject = isParameterObject(schema: param.request?.schema)
        }
        
        var paramsToAdd: [ObjectNameValue]? = []
        if(currentParameterObject != nil){
            let boardParameterObjectConfiguration = extractObjectParam(keyvalue: param.name, object: boardSensorConfiguration)
            currentParameterObject?.forEach{ par in
                paramsToAdd?.append(ObjectNameValue(
                    primitiveType: par.schema,
                    name: par.name,
                    displayName: par.displayName.en,
                    currentValue: extractValueParam(keyvalue: par.name, object: boardParameterObjectConfiguration)
                ))
            }
            return paramsToAdd
        }
        return nil
    }
    
    static func isParameterObject(schema: SchemaContent?) -> [EnumResponseValue]?{
        switch schema {
            case .schemaObject(let schemaObject):
                 return schemaObject.fields
            case .string(_):
                return nil
            case .none:
                return nil
        }
    }
    
    
    // MARK: - Function used to Build Up Different PROPERTY Parameters
    static func buildParameterType(param: PnPLikeContent, boardSensorConfiguration: JSONValue?) -> (ParameterType?, ParameterDetail?) {
        
        var typeIsProperty = false
        var typeIsCommand = false
        
        let typeStr = extractTypeString(schema: param.type)
        let typeStrArr = extractTypeStringArray(schema: param.type)
        
        if(typeStr != nil){
            if(typeStr == "Property"){
                typeIsProperty = true
            }
            if(typeStr == "Command"){
                typeIsCommand = true
            }
        }
        
        if(typeStrArr != nil){
            typeStrArr?.forEach { str in
                if(str == "Property"){
                    typeIsProperty = true
                }
                if(str == "Command"){
                    typeIsCommand = true
                }
            }
        }
        
        if(typeIsProperty){
            
            let schemaString = extractSchemaString(schema: param.schema)
            let schemaObj = extractSchemaObject(schema: param.schema)
            
            if(schemaString != nil){ /// Build STANDARD Properety
                return buildParameterPropertyType(type: nil, param: param, boardSensorConfiguration: boardSensorConfiguration)
            }
            if(schemaObj != nil){ /// Build ENUM / OBJECT Properety
                return buildParameterPropertyType(type: schemaObj?.type, param: param, boardSensorConfiguration: boardSensorConfiguration)
            }
            
        } else if(typeIsCommand){
            
            let schemaString = extractSchemaString(schema: param.request?.schema)
            let schemaObj = extractSchemaObject(schema: param.request?.schema)
            
            if(schemaString == nil && schemaObj == nil){
                return buildParameterCommandType(type: "Empty", param: param, boardSensorConfiguration: boardSensorConfiguration)
            }
            
            if(schemaString != nil){ /// Build STANDARD Command
                return buildParameterCommandType(type: nil, param: param, boardSensorConfiguration: boardSensorConfiguration)
            }
            
            if(schemaObj != nil){ /// Build ENUM / OBJECT Command
                return buildParameterCommandType(type: schemaObj?.type, param: param, boardSensorConfiguration: boardSensorConfiguration)
            }
            
        }
        
        return (nil, nil)
    }
    
    static func buildParameterPropertyType(
        type: String?,
        param: PnPLikeContent,
        boardSensorConfiguration: JSONValue?
    ) -> (ParameterType?, ParameterDetail?) {
        
        switch type{
            
        case "Enum":
            return (
                ParameterType.PropertyEnumeration,
                ParameterDetail(
                    requestName: nil,
                    primitiveType: extractSchemaString(schema: param.schema),
                    currentValue: extractValueParam(
                        keyvalue: param.name,
                        object: boardSensorConfiguration as? JSONValue
                    ),
                    enumValues: extractEnumValues(paramType: ParameterType.PropertyEnumeration, param: param),
                    paramObj: nil
                )
            )
                
        
        case "Object":
            return (
                ParameterType.PropertyObject,
                ParameterDetail(
                    requestName: nil,
                    primitiveType: extractSchemaString(schema: param.schema),
                    currentValue: nil,
                    enumValues: nil,
                    paramObj: buildParameterObject(paramType: ParameterType.PropertyObject, param: param, boardSensorConfiguration: boardSensorConfiguration)
                )
            )
            
    
        default:
            return (
                ParameterType.PropertyStandard,
                ParameterDetail(
                    requestName: nil,
                    primitiveType: extractSchemaString(schema: param.schema),
                    currentValue: extractValueParam(
                        keyvalue: param.name,
                        object: boardSensorConfiguration as? JSONValue
                    ),
                    enumValues: nil,
                    paramObj: nil
                )
            )
            
        }
    }
    
    static func buildParameterCommandType(type: String?, param: PnPLikeContent, boardSensorConfiguration: JSONValue?) -> (ParameterType?, ParameterDetail?) {
        switch type{
            
            case "Empty":
                return (
                    ParameterType.CommandEmpty,
                    ParameterDetail(
                        requestName: nil,
                        primitiveType: nil,
                        enumValues: nil,
                        paramObj: nil
                    )
                )
        
            case "Enum":
                return (
                    ParameterType.CommandEnumeration,
                    ParameterDetail(
                        requestName: param.request?.name,
                        primitiveType: extractSchemaString(schema: param.schema),
                        currentValue: extractValueParam(
                            keyvalue: param.name,
                            object: boardSensorConfiguration as? JSONValue
                        ),
                        enumValues: extractEnumValues(paramType: ParameterType.CommandEnumeration, param: param),
                        paramObj: nil
                    )
                )
            
            
            case "Object":
                return (
                    ParameterType.CommandObject,
                    ParameterDetail(
                        requestName: param.request?.name,
                        primitiveType: extractSchemaString(schema: param.schema),
                        currentValue: nil,
                        enumValues: nil,
                        paramObj: buildParameterObject(paramType: ParameterType.CommandObject, param: param, boardSensorConfiguration: boardSensorConfiguration)
                    )
                )
                
        
            default:
                return (
                    ParameterType.CommandStandard,
                    ParameterDetail(
                        requestName: param.request?.name,
                        primitiveType: extractSchemaString(schema: param.schema),
                        currentValue: extractValueParam(
                            keyvalue: param.name,
                            object: boardSensorConfiguration as? JSONValue
                        ),
                        enumValues: nil,
                        paramObj: nil
                    )
                )
        }
    }
}
