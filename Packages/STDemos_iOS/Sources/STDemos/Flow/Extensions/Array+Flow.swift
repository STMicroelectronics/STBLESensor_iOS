//
//  Array+Flow.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK

enum FlowError: Error {
    case none
    case empty
    case withoutFunctions
    case exceededOdr(description: String?)
    case exceededCount(description: String?)
    case configurationMismatch(sensorName: String)
    
    var localizedDescription: String? {
        switch self {
        case .none:
            return nil
        case .empty:
            return "Select at least one app to play"
        case .withoutFunctions:
            return "Cannot play selected Apps. There are two app composed by only sensors"
        case .exceededOdr(let description):
            return String(format: "Cannot play selected Apps. %@ has excedeed max ble odr value", description ?? "")
        case .exceededCount(let description):
            return String(format: "Cannot play selected Apps. %@", description ?? "")
        case .configurationMismatch(let sensorName):
            return String(format: "Cannot play selected Apps. %@ is present with multiple configurations.", sensorName)
        }
    }
}

extension Array where Element: Flow {
    
    func isValid(_ runningNode: Node) -> FlowError {
        
        if isEmpty {
            return .empty
        }
        
        var allSensors: [Sensor] = [Sensor]()
        
        for flow in self {
            allSensors.append(contentsOf: flow.flatSensor())
        }
        
        let result = allSensors.reduce(into: [String: [Sensor]]()) { result, value in
            result[value.identifier, default: []].append(value)
        }
        
        for key in result.keys {
            let sensors = result[key]
            
            if let sensors = sensors, let firstSensor = sensors.first, sensors.count > 1 {
                
                if !(sensors.allSatisfy { firstSensor.configuration == $0.configuration }) {
                    return .configurationMismatch(sensorName: firstSensor.descr)
                }
                
            }
            
        }
        
        if isWithoutFunctions() {
            return .withoutFunctions
        }
        
        let odrCheck: (result: Bool, description: String?) = odrIsTooHighForBluetoothStreaming()

        if odrCheck.result {
            return .exceededOdr(description: odrCheck.description)
        }

        let functionsCheck: (result: Bool, identifier: String) = isMoreThanOneOfTheSameFunction(with: [ fftFunctionIdentifier,
                                                                                                        quaternionFunctionIdentifier,
                                                                                                        eulerAnglesFunctionIdentifier,
                                                                                                        pedometerFunctionIdentifier,
                                                                                                        hardIronFunctionIdentifier ])
        
        if functionsCheck.result {
            let function = PersistanceService.shared.getFunction(runningNode: runningNode, with: functionsCheck.identifier)
            return .exceededCount(description: function?.descr)
        }
        
        return .none
    }
    
    func isWithoutFunctions() -> Bool {
        
        var without: Int = 0
        
        for flow in self {
            without += flow.inputFunctionsCount(with: nil) == 0 ? 1 : 0
        }
        
        return without > 1
    }
    
    func isMoreThanOneOfTheSameFunction(with functionIdentifiers: [String]) -> (Bool, String) {
        
        var count: Int = 0
        var currentFunction: String = ""
        
        for functionIdentifier in functionIdentifiers {
            count = 0
            currentFunction = functionIdentifier
            
            for flow in self {
                count += flow.inputFunctionsCount(with: functionIdentifier)
            }
            
            if count > 1 {
                break
            }
        }
        
        return (count > 1, currentFunction)
    }
    
    func odrIsTooHighForBluetoothStreaming() -> (Bool, String?) {
        
        for flow in self {
            if !flow.functions.filter({ $0.identifier == fftFunctionIdentifier }).isEmpty {
                continue
            }
            
            if flow.outputs.filter({ $0.identifier == bluetoothOutputIdentifier }).isEmpty {
                continue
            }
            
            for sensor in flow.sensors {
                if let configuration = sensor.configuration?.odr, let max = sensor.bleMaxOdr, configuration > max {
                    return (true, sensor.descr)
                }
            }
        }
        
        return (false, nil)
    }
    
}
