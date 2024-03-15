//
//  Validator.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

enum Result {
    case success
    case failure(String)
    
    func boolValue() -> Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}

protocol Validable {
    associatedtype View
    
    var validators: [Validator<View>] { get set }
    
    func validate() -> Result
    
}

class Validator<T> {
    
    var errorMessage: String = "Error. Value not valid"
    
    func validate(object: T?) -> Result {
        return .failure("error_unknown")
    }
    
}
