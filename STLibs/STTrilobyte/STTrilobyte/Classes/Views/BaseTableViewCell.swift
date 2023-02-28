//
//  BaseTableViewCell.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 24/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

enum Option {
    case editable
    case selected
    case none
}

class BaseTableViewCell<Model>: UITableViewCell, ReusableCell {
    
    var model: Model?
    
    func configure(with model: Model, option: Option = .none) {
        
    }
    
}
