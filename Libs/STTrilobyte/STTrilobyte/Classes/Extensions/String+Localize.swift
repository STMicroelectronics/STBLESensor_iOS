//
//  String+Localize.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 07/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.current(), value: self, comment: "")
    }
    
    func sanitazed() -> String {
        var invalidCharacters = CharacterSet(charactersIn: ":/.")
        invalidCharacters.formUnion(.newlines)
        invalidCharacters.formUnion(.illegalCharacters)
        invalidCharacters.formUnion(.controlCharacters)
        
        return self
            .components(separatedBy: invalidCharacters)
            .joined(separator: "")
    }
}
