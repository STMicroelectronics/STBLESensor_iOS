//
//  UITableView+Helper.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 08/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

extension UITableView {
    /// Register cells with custom class (ex: MyCell.swift + MyCell.xib)
    func registerClassCell(_ cellClass: AnyClass) {
        let nib = UINib(nibName: String(describing: cellClass), bundle: Bundle.current())
        register(nib, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    /// Register cells with no custom class (only a XIB based on default UITableViewCell)
    func registerXibCell(_ cellIdentifier: String) {
        let nib = UINib(nibName: cellIdentifier, bundle: Bundle.current())
        register(nib, forCellReuseIdentifier: cellIdentifier)
    }
}
