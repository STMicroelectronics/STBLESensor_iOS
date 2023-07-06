//
//  UITableView+Extensions.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public enum ReusableCellType {
    case fromStoryboard
    case fromNib
    case fromClass
}

public extension UITableView {
    func register(viewModel: any CellViewModel.Type, type: ReusableCellType = .fromNib, bundle: Bundle = STUI.bundle) {

        switch type {
        case .fromStoryboard:
            // DO NOTHING
            break
        case .fromNib:
            let identifier = String(describing: viewModel.reusableIdentifier)
            register(UINib(nibName: identifier, bundle: bundle), forCellReuseIdentifier: identifier)
        case .fromClass:
            let identifier = String(describing: viewModel.reusableIdentifier)
            register(viewModel.view, forCellReuseIdentifier: identifier)
        }
    }
}
