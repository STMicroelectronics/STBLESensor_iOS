//
//  MaxValueValidator.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 29/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

class MaxValueValidator: Validator<String> {

    let max: Int

    init(with max: Int, errorMessage: String? = nil) {
        self.max = max

        super.init()

        if let text = errorMessage {
            self.errorMessage = text
        }
    }

    override func validate(object: String?) -> Result {
        guard let object = object, let value = Int(object) else { return .failure(errorMessage) }
        return value <= max ? .success : .failure(errorMessage)
    }

}
