//
//  UITableViewCell+Helper.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public extension UITableViewCell {
    var tableView: UITableView? {
        var viewOrNil: UIView? = self
        while let view = viewOrNil {
            if let tableView = view as? UITableView {
                return tableView
            }
            viewOrNil = view.superview
        }
        return nil
    }
}
