//
//  CellViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public protocol CellViewModel: ViewModel {
    var slideActions: [UIContextualAction]? { get }
}

public extension CellViewModel {

    static var view: View.Type {
        View.self
    }

    static var reusableIdentifier: String {
        return String(describing: View.self)
    }

    func configure(view: UITableViewCell) {
        guard let cell = view as? View else { return }
        configure(view: cell)
    }

    func update(view: UITableViewCell, values: [any KeyValue]) {
        guard let cell = view as? View else { return }
        update(view: cell, values: values)
    }
}
