//
//  IntRangeValueValidator.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
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
