//
//  ReusableCell.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 11/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol ReusableCell {
    
}

extension ReusableCell {
    
    static func reusableIdentifier() -> String {
        return String(describing: self)
    }
    
}
