//
//  IoTTemplate+Extensions.swift
//  W2STApp
//
//  Created by Dimitri Giani on 14/06/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation
import SwiftyJSON

extension IoTTemplate {
    
    func getContentForType(_ type: String) -> Content? {
        telemetrySchema?.contents?.first(where: { $0.name?.lowercased() == type.lowercased() })
    }
    
    func getSchemaClassForType(_ type: String) -> SchemaClass? {
        telemetrySchema?.contents?.first(where: { $0.name?.lowercased() == type.lowercased() })?.schema?.schemaClass
    }
    
    func getSchemaTypeForType(_ type: String) -> String? {
        telemetrySchema?.contents?.first(where: { $0.name?.lowercased() == type.lowercased() })?.schema?.schemaValue
    }
    
    var telemetrySchema: SchemaClass? {
        return capabilityModel?.contents?.first(where: { $0.name == "std_comp" })?.schema?.schemaClass
    }
    
    var supportedFeatureTypes: [String] {
        let supportedFeatureTypes: [String] = telemetrySchema?.contents?.compactMap { String($0.name?.lowercased() ?? "") } ?? []
        print(supportedFeatureTypes)
        return supportedFeatureTypes
    }
}
