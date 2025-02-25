//
//  UcfParser.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class UcfParser {
    
    let labelMapper: ValueLabelMapper
    
    var algoNumbers = [String]()
    var algoNames = [String]()
    private(set) var type: VirtualSensorType = .Unknown
    private(set) var regConfig: String = ""
    private(set) var labels: String = ""
    private(set) var ucfFilename: String = ""
    
    init(type: VirtualSensorType, regConfig: String, ucfFilename: String, labels: String) {
        self.type = type
        self.regConfig = regConfig
        self.labels = labels
        self.ucfFilename = ucfFilename
        labelMapper = ValueLabelConsole().buildRegisterMapperFromString(labels) ?? Self.createDefaultValueLabelMapper(type: type)
    }
    
    init?(ucf: URL) {
        var mlcLabels: String = ""
        var fsmLabels: String = ""
        var fileString: String = ""
        var steval_supported: Bool = false
        var stmc_page: Bool = false
        var mlc_enabled: Bool = false
        var fsm_enabled: Bool = false
        
        do {
            let fileHandler = try FileHandle(forReadingFrom: ucf)
            let data = fileHandler.readDataToEndOfFile()
            fileHandler.closeFile()
            if let tmp = String(bytes: data, encoding: .utf8) {
                fileString = tmp
            } else {
                return nil
            }
        } catch {
            return nil
        }
        
        ucfFilename = ucf.lastPathComponent
        var lines = fileString.split(separator: "\n") /* \r\n */

        
        for line in lines {
            let sensorTileBoxType = UserDefaults.standard.string(forKey: "SensorTileBoxType") ?? "SENSOR_TILE_BOX"
            if(sensorTileBoxType == "SENSOR_TILE_BOX"){
                if (line.contains("LSM6DSOX")) {
                    steval_supported = true
                }
            } else {
                if (line.contains("LSM6DSV16X")) {
                    steval_supported = true
                }
            }
            if (line.contains("<MLC") && line.contains("_SRC>")) {
                if let index = line.firstIndex(of: "<") {
                    mlcLabels.append(String(line[index...]))
                    mlcLabels.append(";")
                }
            }
            if (line.contains("<FSM_OUTS") && line.contains(">")) {
                if let index = line.firstIndex(of: "<") {
                    fsmLabels.append(String(line[index...]))
                    fsmLabels.append(";")
                }
            }
            if (line.contains("Ac")) {
                let sep = line.split(separator: " ")
                let reg = sep[1]
                let val = sep[2]
                regConfig.append(String(reg))
                regConfig.append(String(val))
                
                if (reg == "01" && val == "80") {
                    stmc_page = true
                } else if (reg == "01" && val == "00") {
                    stmc_page = false
                }
                
                if (stmc_page) {
                    if (reg == "05") {
                        if let val_int = Int(val, radix: 16) {
                            mlc_enabled = (val_int & 0x10) != 0
                            fsm_enabled = (val_int & 0x01) != 0
                        }
                    }
                }
            }
        }
        
        if (steval_supported) {
            var labelMapperDefault: ValueLabelMapper? = nil
            if (!mlc_enabled && !fsm_enabled) {
                type = .None
            }else if (mlc_enabled && !fsm_enabled) {
                type = .MLCVirtualSensor
                labels = mlcLabels
                labelMapperDefault = UcfParser.createDefaultValueLabelMapper(type: .MLCVirtualSensor)
            }
            else if (!mlc_enabled && fsm_enabled) {
                type = .FSMVirtualSensor
                labels = fsmLabels
                labelMapperDefault = UcfParser.createDefaultValueLabelMapper(type: .FSMVirtualSensor)
            }
            else if (mlc_enabled && fsm_enabled) {
                type = .Both
            }
            let labelMapperFromFile = ValueLabelConsole().buildRegisterMapperFromString(labels)
            guard let labelMapperDefaultTmp = labelMapperDefault else { return nil }
            labelMapper = labelMapperFromFile ?? labelMapperDefaultTmp
        } else {
            return nil
        }
    }
    
    static func createDefaultValueLabelMapper(type: VirtualSensorType) -> ValueLabelMapper {
        
        let labelMapper = ValueLabelMapper()
        let nAlgos = type == .MLCVirtualSensor ? 8 : 16
        let iOffset = type == .MLCVirtualSensor ? 0 : 1
        for i in 0..<nAlgos {
            let algoDefaultNameFormat = type == .MLCVirtualSensor ? "DT%1d" : (i < 10 ? "FSM%1d" : "FSM%2d")
            // fsm register start from 1, mlc register start from 0
            let register = ValueLabelMapper.RegisterIndex(i + iOffset)
            // always start from 1
            let label = String(format: algoDefaultNameFormat, i + 1)
            labelMapper.addRegisterName(register: register, label: label)
        }
        
        return labelMapper
    }
    
    static func encodeLabelMapper(type: VirtualSensorType, labelMapper: ValueLabelMapper) -> String {
        var str = ""
        let nAlgos = type == .MLCVirtualSensor ? 8 : 16
        
        let iOffset = type == .MLCVirtualSensor ? 0 : 1
        for i in 0..<nAlgos {
            let algoDefaultNameFormat = type == .MLCVirtualSensor ? "DT%1d" : (i < 10 ? "FSM%1d" : "FSM%2d")
            let regNameFormat = type == .MLCVirtualSensor ? "<MLC%1d_SRC>" : (i < 10 ? "<FSM_OUTS%1d>" : "<FSM_OUTS%2d>")
            
            str.append(String(format: regNameFormat, i + iOffset))
            let register = ValueLabelMapper.RegisterIndex(i)
            let algoName = labelMapper.algorithmName(register: register) ?? String(format: algoDefaultNameFormat, i + iOffset)
            str.append(algoName)
            
            labelMapper.getLabelValues(index: register)?.forEach {
                let key = String($0.key)
                let value = $0.value
                str.append(",\(key)='\(value)'")
            }
            str.append(";")
        }
        
        return str
    }
    

}

