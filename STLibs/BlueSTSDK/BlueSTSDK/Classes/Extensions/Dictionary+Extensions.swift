//
//  Dictionary+Extensions.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 03/05/21.
//

import Foundation

public extension Dictionary {
    func union(_ dictionaries: Dictionary...) -> Dictionary {
        var result = self
        
        dictionaries.forEach { (dictionary) -> Void in
            dictionary.forEach { (key, value) -> Void in
                _ = result.updateValue(value, forKey: key)
            }
        }
        
        return result
        
    }
}
