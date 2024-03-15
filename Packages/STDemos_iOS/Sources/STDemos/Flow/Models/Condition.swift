//
//  Condition.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

struct Condition {
    
    var expression: Flow?
    var executes: [Flow] = [Flow]()
    
}

extension Condition: Uploadable {
    func data() -> Data? {

        var dictionary: [String: Any] = [String: Any]()

        dictionary["expression"] = expression?.flatJsonDictionary()

        dictionary["statements"] = executes.map {
            $0.flatJsonDictionary()
        }

        guard let conditionData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            return nil
        }

        return conditionData
    }
}
