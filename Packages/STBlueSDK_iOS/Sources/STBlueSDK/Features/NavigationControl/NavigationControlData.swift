//
//  NavigationControlData.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct NavigationControlData {
    
    public let fakevalue: FeatureField<String>
    
    init(with data: Data, offset: Int) {
        
        let fakevalue = "Place holder"
        
        self.fakevalue = FeatureField<String>(name: "name",
                                               uom: nil,
                                               min: nil,
                                               max: nil,
                                               value: fakevalue)
    }
    
}

extension NavigationControlData: CustomStringConvertible {
    public var description: String {
        
        let fakevalue = fakevalue.value ?? "nil"
        
        return String(format: "name: %s", fakevalue)
    }
}

extension NavigationControlData: Loggable {
    public var logHeader: String {
        "\(fakevalue.logHeader)"
    }
    
    public var logValue: String {
        "\(fakevalue.logValue)"
    }
    
}
