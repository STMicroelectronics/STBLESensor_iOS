//
//  Condition.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 18/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
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
