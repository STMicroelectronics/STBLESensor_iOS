//
//  IntRangeValueValidator.swift
//  trilobyte-lib-ios
//
//  Created by Giovanni Visentini on 20/06/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

class IntRangeValueValidator: Validator<String> {
    
    let validRange:ClosedRange<Int>
    
    init(min:Int?, max:Int?, errorMessage: String? = nil) {
        self.validRange = (min ?? Int.min) ... (max ?? Int.max)
        
        super.init()
        
        if let text = errorMessage {
            self.errorMessage = text
        }
    }
    
    override func validate(object: String?) -> Result {
        guard let object = object, let value = Int(object) else { return .failure(errorMessage) }
        return validRange.contains(value) ? .success : .failure(errorMessage)
    }
    
}
