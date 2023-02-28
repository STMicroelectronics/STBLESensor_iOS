//
//  Validator.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 28/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
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
    
    var errorMessage: String = "error_email_not_valid".localized()
    
    func validate(object: T?) -> Result {
        return .failure("error_unknown")
    }
    
}
