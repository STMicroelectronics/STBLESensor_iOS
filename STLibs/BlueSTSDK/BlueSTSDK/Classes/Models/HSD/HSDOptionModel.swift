//
//  HSDOptionModel.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 26/01/21.
//

import Foundation

public class HSDOptionModel {
    public enum Mode {
        case odr
        case fs
    }
    
    public let mode: Mode
    public let name: String
    public let unit: String?
    public let values: [Double]
    public let selected: Double
    
    init(mode: Mode, name: String, unit: String?, values: [Double], selected: Double) {
        self.mode = mode
        self.name = name
        self.unit = unit
        self.values = values
        self.selected = selected
    }
}
