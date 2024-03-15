//
//  Flow.swift
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

let flowDefaultName = "New flow"

typealias Flows = [Flow]

extension Flows: Uploadable where Element: Flow {
    func data() -> Data? {
        
        var containsExpOrStatement = false
        
        var jsonObjectFlow: [String: Any] = [:]
        var jsonFlows: [[String : Any]] = [[:]]
        
        self.forEach{ flow in
//            if (flow.expression != nil || (flow.statements != nil && !(flow.statements!.isEmpty))) {
            if (flow.expression != nil || (flow.statements != nil && !(flow.statements?.count == 0))) {
                containsExpOrStatement = true
                jsonObjectFlow = flow.createDictExpression()
            } else {
                jsonFlows = map {
                    $0.flatJsonDictionary()
                }
            }
        }

        if(containsExpOrStatement) {
            guard let flowData = try? JSONSerialization.data(withJSONObject: jsonObjectFlow) else { return nil }
            return flowData
        } else {
            guard let flowData = try? JSONSerialization.data(withJSONObject: jsonFlows) else { return nil }
            return flowData
        }
    }
    
    private func hasOutput(_ type:String) -> Bool{
        let validOutputFlows = self.filter { $0.outputs.contains { $0.identifier == type } }
        
        return !validOutputFlows.isEmpty
    }
    
    var hasBLEOutput:Bool{
        return hasOutput(bluetoothOutputIdentifier)
    }
    
    var hasSDOutput:Bool{
        return hasOutput(SDOutputIdentifier)
    }
    
    var duration:TimeInterval?{
        return self.compactMap{ $0.duration }.max()
    }
}

public final class Flow: Checkable {
    var identifier: String = UUID().uuidString
    var category: String?
    var boardCompatibility: [String]?
    var name: String = flowDefaultName
    var descr: String {
        return name
    }
    var icon: String {
        return itemIcon
    }
    var expression: Flow?
    var statements: [Flow]? = [Flow]()
    var functions: [Function] = [Function]()
    var sensors: [Sensor] = [Sensor]()
    var flows: [Flow] = [Flow]()
    var outputs: [Output] = [Output]()
    var notes: String?
    var version: Int = minFwVersion
}

extension Flow {
    func add(sensor: Sensor) {
        
        defer {
            for flow in flows {
                flow.update(sensor: sensor)
            }
        }
        
        let index = sensors.firstIndex {
            $0 == sensor
        }
        
        guard let currentIndex = index else {
            sensors.append(sensor)
            return
        }
        
        let currentSensor: Sensor? = sensors[currentIndex]
        
        guard let unwrappedCurrentSensor = currentSensor else {
            return
        }
        
        unwrappedCurrentSensor.configuration = sensor.configuration
    }
    
    func add(flow: Flow) {
        
        defer {
            for sensor in sensors {
                for flow in flows {
                    flow.update(sensor: sensor)
                }
            }
        }
        
        let index = flows.firstIndex { $0 == flow }
        
        guard index != nil else {
            flows.append(flow)
            return
        }
    }

    func add(output: Output) {
        let exsists = outputs.contains { $0.identifier == output.identifier }

        if !exsists {
            outputs.append(output)
        }
    }
    
    func add(function: Function) {
        functions.append(function)
    }
    
    func update(sensor: Sensor) {
        
        defer {
            for flow in flows {
                flow.update(sensor: sensor)
            }
        }
        
        let index = sensors.firstIndex { $0 == sensor }
        
        if let currentIndex = index {
            let currentSensor: Sensor? = sensors[currentIndex]
            
            guard let unwrappedCurrentSensor = currentSensor else {
                return
            }
            
            unwrappedCurrentSensor.configuration = sensor.configuration
        }
    }
    
    var duration:TimeInterval?{
        let temp = sensors.compactMap{$0.configuration?.acquisitionTime}.max()
        if let maxAcquisition = temp,
            maxAcquisition > 0 {
            return TimeInterval(maxAcquisition)
        }
        return nil
        
    }
}

extension Flow: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Flow: FlowItem {
    var itemIcon: String {
        
        if outputs.count == 1, let output = outputs.first {
            return output.itemIcon
        }
    
        return "ic_multi_output"
    }
    
    func hasSettings() -> Bool {
        return false
    }
}

extension Flow: Equatable {
    public static func == (lhs: Flow, rhs: Flow) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Flow {
    
    var inputs: [FlowItem] {
        return sensors + flows
    }

    var hasOutputAsInput: Bool {
        return self.outputs.contains { output -> Bool in
            outputAsInputIdentifier.contains(output.identifier)
        }
    }

    var hasOutputAsExp: Bool {
        return self.outputs.contains { $0.identifier == expOutputIdentifier }
    }

    var hasPhysicalOutput: Bool {
        return self.outputs.contains { output -> Bool in
            outputPhysicalIdentifier.contains(output.identifier)
        }
    }
    
    func addOrUpdate(items: [FlowItem]) {
        for item in items {
            if let sensor = item as? Sensor {
                add(sensor: sensor)
            } else if let flow = item as? Flow {
                add(flow: flow)
            } else if let output = item as? Output {
                add(output: output)
            } else if let function = item as? Function {
                add(function: function)
            }
        }
    }
    
    func addOrUpdate(item: FlowItem) {
        addOrUpdate(items: [item])
    }
    
    func remove(items: [FlowItem]) {
        for item in items {
            if item as? Sensor != nil, let index = sensors.firstIndex(where: { $0.identifier == item.identifier }) {
                sensors.remove(at: index)
            } else if item as? Flow != nil, let index = flows.firstIndex(where: { $0.identifier == item.identifier }) {
                flows.remove(at: index)
            } else if item as? Output != nil, let index = outputs.firstIndex(where: { $0.identifier == item.identifier }) {
                outputs.remove(at: index)
            } else if item as? Function != nil, let index = functions.firstIndex(where: { $0.identifier == item.identifier }) {
                functions.remove(at: index)
            }
        }
    }
    
    func remove(input: FlowItem) {
       remove(items: [input])
    }
    
    func flatSensor() -> [Sensor] {
        var sensors: Set<Sensor> = Set<Sensor>()

        self.sensors.forEach { member in
            sensors.insert(member)
        }
        
        for flow in self.flows {
            
            for sensor in flow.sensors {
                sensors.insert(sensor)
            }
            
            flow.flatSensor().forEach { member in
                sensors.insert(member)
            }
            
        }
        
        return Array(sensors)
    }
    
    func flatFlow() -> [Flow] {
        var flows: [Flow] = [Flow]()
        
        flows.append(self)
        
        for flow in self.flows {
            flows.append(contentsOf: flow.flatFlow())
        }
        
        return flows
    }
    
    func createDictExpression() -> [String: Any] {
        var dictionary: [String: Any] = [String: Any]()

        if let expression = self.expression {
            dictionary["expression"] = expression.flows[0].flatJsonDictionary()
        }

        if let statements = self.statements {
            if !statements.isEmpty {
                dictionary["statements"] = statements[0].flows.map {
                    $0.flatJsonDictionary()
                }
            }
        }
        
        return dictionary
    }
    
    func flatJsonDictionary() -> [String: Any] {
        let sensors: [[String: Any]] = flatSensor().map { $0.jsonDictionary() }
        let flows: [[String: Any]] = flatFlow().map { $0.jsonDictionary() }
        
        var dictionary: [String: Any] = [String: Any]()
        
        dictionary["version"] = version
        dictionary["sensors"] = sensors
        dictionary["flows"] = flows
        
        return dictionary
    }
    
    // Restituisce i sensori presenti come input al flow corrente
    func inputSensors() -> [Sensor] {
        var sensors: [Sensor] = [Sensor]()
        
        sensors.append(contentsOf: self.sensors)
        
        for flow in self.flows where flow.functions.isEmpty {
            
            sensors.append(contentsOf: flow.inputSensors())
        }
        
        return sensors
    }
    
    // Restituisce le funzioni presenti come input al flow corrente
    func inputFunctions() -> [Function] {
        var functions: [Function] = [Function]()
        
        for flow in self.flows {
            
            if flow.functions.isEmpty {
                functions.append(contentsOf: flow.inputFunctions())
            } else {
                if let last = flow.functions.last {
                    functions.append(last)
                }
            }
        }
        
        return functions
    }
    
    func availableOutputs(runningNode node: Node) -> [Output] {
        
        let outputIdentifiers = availableOutputIdentifiers().map { Set($0) }
        
        guard var outputInsersection = outputIdentifiers.first else { return [] }
        
        for outputSet in outputIdentifiers {
            outputInsersection = outputInsersection.intersection(outputSet)
        }
        
        let allOutputs = PersistanceService.shared.getAllOutputs(runningNode: node)
        
        return outputInsersection.compactMap { output in
            allOutputs.first { $0.identifier == output }
        }
    }
    
    func availableOutputIdentifiers() -> [[String]] {
        var outputs: [[String]] = [[String]]()
        
        if let lastFunction = functions.last {
            outputs.append(lastFunction.outputs)
        } else {
            let currentSensorsOutputs = sensors.map { $0.outputs ?? [] }
            outputs += currentSensorsOutputs
            
            for child in flows {
                outputs += child.availableOutputIdentifiers()
            }
        }
        
        return outputs
    }
    
    func inputFunctionsCount(with identifier: String?) -> Int {
        var count: Int = 0
        
        if let identifier = identifier {
            count += functions.filter { $0.identifier == identifier }.count
        } else {
            count += functions.count
        }
        
        for flow in self.flows {
            count += flow.inputFunctionsCount(with: identifier)
        }
        
        return count
    }
    
    func jsonDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [String: Any]()
        
        dictionary["id"] = identifier
        dictionary["sensors"] = sensors.map { $0.identifier }
        dictionary["flows"] = flows.map { $0.identifier }
        dictionary["functions"] = functions.map { $0.jsonDictionary() }
        dictionary["outputs"] = outputs.map { $0.jsonDictionary() }

        return dictionary
    }
    
    func countInvocation(of function: Function) -> Int {
        var count: Int = 0
        
        for funct in functions where function.identifier == funct.identifier {
            count += 1
        }
        
        for child in flows {
            count += child.countInvocation(of: function)
        }
        
        return count
    }
    
    func hasValidOutputs() -> Bool {
        let noOutputsAsInput = Set(outputs.map { $0.identifier }).isDisjoint(with: outputAsInputIdentifier)
        let noOutputsPhysical = Set(outputs.map { $0.identifier }).isDisjoint(with: outputPhysicalIdentifier)
        
        return (noOutputsAsInput || noOutputsPhysical)
    }
}

extension Flow: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case boardCompatibility = "board_compatibility"
        case category
        case name = "description"
        case functions
        case sensors
        case flows
        case outputs
        case notes
        case version
        case expression
        case statements
    }
}

extension Flow: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Flow()
        
        copy.identifier = self.identifier
        copy.boardCompatibility = self.boardCompatibility
        copy.category = self.category
        copy.name = self.name
        copy.functions = self.functions
        copy.sensors = self.sensors
        copy.flows = self.flows
        copy.outputs = self.outputs
        copy.notes = self.notes
        copy.version = self.version
        copy.statements = self.statements
        copy.expression = self.expression
        
        return copy
    }
}

public struct FlowAndNodeParam {
    public let flow: Flow
    public let node: Node
}

public struct FlowsAndNodeParam {
    public let flows: [Flow]
    public let node: Node
}

public struct SensorAndNodeParam {
    public let sensor: Sensor
    public let node: Node
}

public struct FunctionAndSensorParam {
    let function: Function
    public let sensor: Sensor?
}
