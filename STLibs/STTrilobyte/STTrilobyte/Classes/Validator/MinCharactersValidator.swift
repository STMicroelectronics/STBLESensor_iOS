//
//  MinCharactersValidator.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 28/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

class MinCharactersValidator: Validator<String> {
    
    let min: Int
    
    init(with min: Int, errorMessage: String? = nil) {
        self.min = min
        
        super.init()
        
        if let text = errorMessage {
            self.errorMessage = text
        }
    }
    
    override func validate(object: String?) -> Result {
        return object?.count ?? 0 >= min ? .success : .failure(errorMessage)
    }
    
}
