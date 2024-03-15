//
//  MinValueValidator.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class MinValueValidator: Validator<String> {

    let min: Int

    init(with min: Int, errorMessage: String? = nil) {
        self.min = min

        super.init()

        if let text = errorMessage {
            self.errorMessage = text
        }
    }

    override func validate(object: String?) -> Result {
        guard let object = object, let value = Int(object) else { return .failure(errorMessage) }
        return value >= min ? .success : .failure(errorMessage)
    }

}
