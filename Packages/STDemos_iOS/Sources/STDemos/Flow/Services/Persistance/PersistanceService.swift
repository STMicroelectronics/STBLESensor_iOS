//
//  PersistanceService.swift
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

struct PersistanceService {
    static let shared = PersistanceService()
    
    @discardableResult
    func save(flow: Flow) -> Bool {
        let name = flow.name.sanitazed()
        let fileName = FileManager.default.customFlowsFolder().appendingPathComponent(name + ".json")
        guard let data = try? JSONEncoder().encode(flow) else { return false }
        
        if FileManager.default.fileExists(atPath: fileName.path) {
            guard (try? FileManager.default.removeItem(atPath: fileName.path)) != nil else { return false }
        }
        
        return FileManager.default.createFile(atPath: fileName.path, contents: data, attributes: nil)
    }
    
    @discardableResult
    func delete(flow: Flow) -> Bool {
        let name = flow.name.sanitazed()
        let fileName = FileManager.default.customFlowsFolder().appendingPathComponent(name + ".json")
        
        do {
            try FileManager.default.removeItem(atPath: fileName.path)
        } catch {
            return false
        }
        
        return true
    }
    
    func exists(flow: Flow) -> Bool {
        return FileManager.default.flowExists(with: flow.name)
    }
    
    // MARK: - FLOWS
    
    func getAllPreloadedFlows() -> [Flow] {
        let bundle = STDemos.bundle
        
        guard let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) else { return [] }
        
        return loadFlowsFrom(urls: urls)
    }
    
    func getAllCustomFlows() -> [Flow] {
        FileManager.default.createFlowsFolderIfNeeded()
        
        guard let urls = try? FileManager.default.contentsOfDirectory(at: FileManager.default.customFlowsFolder(), includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return [] }
        
        return loadFlowsFrom(urls: urls)
    }
    
    func getLogicAsInputFlows(runningNode node: Node) -> [Flow] {
        
        let bundle = STDemos.bundle
        
        guard let url = bundle.url(forResource: "exp_flows", withExtension: "json") else { return [] }
        
        guard let flows: [Flow] = load(from: url) else { return [] }
        
        return flows.filter{ $0.boardCompatibility?.contains { $0.replacingOccurrences(of: "_", with: "").lowercased() == node.type.stringValue.replacingOccurrences(of: "_", with: "").lowercased() } ?? false }
    }

    func getCounterFlows(runningNode node: Node) -> [Flow] {

        let bundle = STDemos.bundle

        guard let url = bundle.url(forResource: "counter_flows", withExtension: "json") else { return [] }

        guard let flows: [Flow] = load(from: url) else { return [] }
        
        return flows.filter{ $0.boardCompatibility?.contains { $0.replacingOccurrences(of: "_", with: "").lowercased() == node.type.stringValue.replacingOccurrences(of: "_", with: "").lowercased() } ?? false }
    }

    func getAllFlows() -> [Flow] {
        return getAllPreloadedFlows() + getAllCustomFlows()
    }
    
    // MARK: - FUNCTIONS
    
    func getLogicFunctions(runningNode node: Node) -> [Function] {
        return getAllFunctions(runningNode: node).filter { $0.isLogic }
    }
    
    func getFunction(runningNode node: Node, with identifier: String) -> Function? {
        return getAllFunctions(runningNode: node).first { $0.identifier == identifier }
    }
    
    func getFunctionIDs(with flow: Flow) -> [String] {
        
        var functionIDs: [String] = [String]()
        
        if let lastFunction = flow.functions.last {
            return [lastFunction.identifier]
        } else {
            for childFlow in flow.flows {
                functionIDs.append(contentsOf: getFunctionIDs(with: childFlow))
                if !functionIDs.isEmpty {
                    continue
                }
            }
        }
        
        return functionIDs
    }
    
    func getSensorIDs(with flow: Flow) -> [String] {
        
        var sensorIDs: Set<String> = []
        flow.sensors.forEach{
            sensorIDs.insert($0.identifier)
        }
        
        for childFlow in flow.flows where childFlow.functions.isEmpty {
            let sensors = getSensorIDs(with: childFlow)
            sensors.forEach{
                sensorIDs.insert($0)
            }
        }
        
        return Array(sensorIDs)
    }
    
    func getAllFunctions(runningNode node: Node) -> [Function] {
        let bundle = STDemos.bundle
        guard let url = bundle.url(forResource: "functions", withExtension: "json") else { return [] }
        guard let functions: [Function] = load(from: url) else { return [] }

        return functions.filter{ $0.boardCompatibility?.contains { $0.replacingOccurrences(of: "_", with: "").lowercased() == node.type.stringValue.replacingOccurrences(of: "_", with: "").lowercased() } ?? false }
    }
    
    // MARK: - SENSORS
    
    func getAllSensors(runningNode node: Node) -> [Sensor] {
        let bundle = STDemos.bundle
        
        guard let url = bundle.url(forResource: "sensors", withExtension: "json") else { return [] }
        
        guard let sensors: [Sensor] = load(from: url) else { return [] }

        return sensors.filter{ $0.boardCompatibility?.contains { $0.replacingOccurrences(of: "_", with: "").lowercased() == node.type.stringValue.replacingOccurrences(of: "_", with: "").lowercased() } ?? false }
    }
    
    // MARK: - OUTPUTS
    
    func getAllOutputs(runningNode node: Node) -> [Output] {
        let bundle = STDemos.bundle
        
        guard let url = bundle.url(forResource: "output", withExtension: "json") else { return [] }
        
        guard let outputs: [Output] = load(from: url) else { return [] }

        return outputs.filter{ $0.boardCompatibility?.contains { $0.replacingOccurrences(of: "_", with: "").lowercased() == node.type.stringValue.replacingOccurrences(of: "_", with: "").lowercased() } ?? false }
    }

    // MARK: - FILTERS

    func getAllFilters(runningNode node: Node) -> [Filter] {
        let bundle = STDemos.bundle

        guard let url = bundle.url(forResource: "filters", withExtension: "json") else { return [] }

        guard let filters: [Filter] = load(from: url) else { return [] }

        return filters.filter{ $0.boardCompatibility?.contains { $0.replacingOccurrences(of: "_", with: "").lowercased() == node.type.stringValue.replacingOccurrences(of: "_", with: "").lowercased() } ?? false }
    }

    func getFiltersBy(runningNode node: Node, _ sensorId: String, powerMode: PowerMode.Mode, odr: Double) -> FilterElement? {
        let valuesBySensor = getAllFilters(runningNode: node).first { $0.sensorID == sensorId }?.values
        let valueByPowerMode = valuesBySensor?.first { $0.powerModes.contains { $0.self == powerMode } }
        let filterElementByOrd = valueByPowerMode?.filters.first { $0.odrs.contains(odr) }
        return filterElementByOrd
    }
}

private extension PersistanceService {
    func loadFlowsFrom(urls: [URL]) -> [Flow] {
        var flows = [Flow]()
        
        for url in urls {
            if let flow: Flow = load(from: url) {
                flows.append(flow)
            }
        }
        
        return flows.sorted { $0.descr < $1.descr }
    }
    
    func load<T: Decodable>(from url: URL) -> T? {
        
        let string = try? String(contentsOfFile: url.path)
        
        guard let data = string?.data(using: .utf8) else {
            return nil
        }
        
        var res: T?
        
        do {
            try res = JSONDecoder().decode(T.self, from: data)
        } catch {
            print(error)
        }
        
        return res
    }
}
