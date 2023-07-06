//
//  ValueLabelConsole.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class ValueLabelConsole {
    private static let REGISTER_INFO =  try! NSRegularExpression(pattern:"<(MLC|FSM_OUTS|STREDL)(\\d+)(_SRC)?>(.*)")
    private static let VALUE_INFO =  try! NSRegularExpression(pattern:"(\\d+)='(.*)'")

    private var mResponseStr:String = ""

    public func buildRegisterMapperFromString(_ response: String) -> ValueLabelMapper?{
        print("Str:",response)
        let registerData = response.split(separator: ";")
        let mapper = ValueLabelMapper()
        for data in registerData {
            let splitData = data.split(separator: ",")
            guard let (registerId, algoName) = extractRegisterInfo(registerInfo: String(splitData[0]))else{
                return mapper
            }
            mapper.addRegisterName(register: registerId, label: algoName)
            for i in 1..<splitData.count{
                guard let (value,name) = extractValueInfo(valueInfo: String(splitData[i])) else{
                    return mapper
                }
                mapper.addLabel(register: registerId, value: value, label: name)
            }
        }
        return mapper
        
    }
    
    private func extractRegisterInfo(registerInfo: String) -> (UInt8, String)? {
        let matches =  Self.REGISTER_INFO.matches(in: registerInfo, options: [], range: NSMakeRange(0, registerInfo.count))
        guard matches.count > 0 else{
            return nil
        }
        let match = matches[0]
        if let idRange = Range(match.range(at: 2), in: registerInfo),
           let nameRange = Range(match.range(at: 4), in: registerInfo),
           var id = UInt8(registerInfo[idRange]){
           let registerTypeRange = Range(match.range(at: 1), in: registerInfo)
            if(registerInfo[registerTypeRange!] == "FSM_OUTS"){
                id = id - 1
            }
            return (id,String(registerInfo[nameRange]))
        }else{
            return nil
        }
    }
    
    private func extractValueInfo(valueInfo: String) -> (UInt8, String)? {
        let matches =  Self.VALUE_INFO.matches(in: valueInfo, options: [], range: NSMakeRange(0, valueInfo.count))
        guard matches.count > 0 else{
            return nil
        }
        let match = matches[0]
        if let idRange = Range(match.range(at: 1), in: valueInfo),
           let nameRange = Range(match.range(at: 2), in: valueInfo),
           let id = UInt8(valueInfo[idRange]){
            return (id,String(valueInfo[nameRange]))
        }else{
            return nil
        }
    }
}


