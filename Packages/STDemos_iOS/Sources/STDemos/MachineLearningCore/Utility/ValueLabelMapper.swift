//
//  ValueLabelMapper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class ValueLabelMapper{
    
    typealias RegisterIndex=UInt8
    
    public var registerName:[RegisterIndex:String] = [:]
    public var labelValue:[RegisterIndex:[UInt8:String]] = [:]

    func addLabel(register:RegisterIndex,value:UInt8,label:String){
        var registerMap = labelValue[register] ?? [:]
        registerMap[value]=label
        labelValue[register] = registerMap
    }
    
    func addRegisterName(register:RegisterIndex, label:String){
        registerName[register] = label
    }
    
    func valueName(register:RegisterIndex,value:UInt8) ->String?{
        return labelValue[register]?[value]
    }
    
    func algorithmName(register:RegisterIndex) -> String?{
        return registerName[register]
    }
    
}
