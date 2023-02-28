//
//  IoTDevice+Extensions.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import SwiftyJSON

extension IoTDevice {
    static func json(device: IoTDevice, _ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample, dtmiFeatureName: String) -> JSON? {
        
        let actualSample = sample
        let actualDtmiName = dtmiFeatureName
        
        var json: JSON?
        
        if let content = device.ioTtemplate?.getContentForType(actualDtmiName),
           let schema = device.ioTtemplate?.getSchemaClassForType(actualDtmiName),
           let name = content.name,
           schema.schemaType == .object {
            
            var i = 0
            json = JSON()
            
            if !(schema.fields==nil){
                var jsonData: JSON = JSON()
                for field in schema.fields!{
                    if(i <= actualSample.data.count - 1){
                        jsonData = try! jsonData.merged(with: JSON([field.name!: actualSample.data[i].doubleValue.rounded(toPlaces: 3)]))
                        i += 1
                    }
                }
                json?[name] = jsonData
            }
            
        }else{
            
            if let content = device.ioTtemplate?.getContentForType(feature.name),
               let name = content.name {
                json = JSON([name: actualSample.data[0].doubleValue.rounded(toPlaces: 3)])
            }
            
        }
        
        return json
    }
    
}
