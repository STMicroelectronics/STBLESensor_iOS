//
//  PersistanceService.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 10/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

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
        let bundle = Bundle.current()
        
        guard let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) else { return [] }
        
        return loadFlowsFrom(urls: urls)
    }
    
    func getAllCustomFlows() -> [Flow] {
        FileManager.default.createFlowsFolderIfNeeded()
        
        guard let urls = try? FileManager.default.contentsOfDirectory(at: FileManager.default.customFlowsFolder(), includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return [] }
        
        return loadFlowsFrom(urls: urls)
    }
    
    func getLogicAsInputFlows() -> [Flow] {
        
        let bundle = Bundle.current()
        
        guard let url = bundle.url(forResource: "exp_flows", withExtension: "json") else { return [] }
        
        guard let flows: [Flow] = load(from: url) else { return [] }
        
        return flows
    }

    func getCounterFlows() -> [Flow] {

        let bundle = Bundle.current()

        guard let url = bundle.url(forResource: "counter_flows", withExtension: "json") else { return [] }

        guard let flows: [Flow] = load(from: url) else { return [] }

        return flows
    }

    func getAllFlows() -> [Flow] {
        return getAllPreloadedFlows() + getAllCustomFlows()
    }
    
    // MARK: - FUNCTIONS
    
    func getLogicFunctions() -> [Function] {
        return getAllFunctions().filter { $0.isLogic }
    }
    
    func getFunction(with identifier: String) -> Function? {
        return getAllFunctions().first { $0.identifier == identifier }
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
    
    func getAllFunctions() -> [Function] {
        let bundle = Bundle.current()
        guard let url = bundle.url(forResource: "functions", withExtension: "json") else { return [] }
        guard let functions: [Function] = load(from: url) else { return [] }
        return functions.sorted { $0.descr < $1.descr }
    }
    
    // MARK: - SENSORS
    
    func getAllSensors() -> [Sensor] {
        let bundle = Bundle.current()
        
        guard let url = bundle.url(forResource: "sensors", withExtension: "json") else { return [] }
        
        guard let sensors: [Sensor] = load(from: url) else { return [] }
        
        return sensors
    }
    
    // MARK: - OUTPUTS
    
    func getAllOutputs() -> [Output] {
        let bundle = Bundle.current()
        
        guard let url = bundle.url(forResource: "output", withExtension: "json") else { return [] }
        
        guard let outputs: [Output] = load(from: url) else { return [] }
        
        return outputs
    
    }

    // MARK: - FILTERS

    func getAllFilters() -> [Filter] {
        let bundle = Bundle.current()

        guard let url = bundle.url(forResource: "filters", withExtension: "json") else { return [] }

        guard let filters: [Filter] = load(from: url) else { return [] }

        return filters
    }

    func getFiltersBy(_ sensorId: String, powerMode: PowerMode.Mode, odr: Double) -> FilterElement? {
        let valuesBySensor = getAllFilters().first { $0.sensorID == sensorId }?.values
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
