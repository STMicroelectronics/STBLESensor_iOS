//
//  GenericDataSample+json.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import TrackerThresholdUtil
import SwiftyJSON

extension GenericSample {
    
    var toSplittedJson: [JSON] {
        var splitted: [JSON] = []
        splitted.append(GenericSample(id: id, type: type, date: date, value: value, technologySource: technologySource).toJson)
        return splitted
    }
    
    var toJson: JSON {
        var obj = JSON()
        try? obj.merge(with: date?.toJson ?? Date().toJson)
        
        var measure: String = ""
        var value: Float = 0.0
        
        obj["t"].string = self.type
        obj["v"].float = Float(self.value ?? 0.0)
        
        if(technologySource != nil){
            var objTech = JSON()
            objTech["tech"].string = technologySource
            obj["metadata"] = objTech
        }
        
        return obj
    }
}
