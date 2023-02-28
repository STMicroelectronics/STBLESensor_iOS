//
//  MinValueValidator.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 23/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
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
