//
//  BaseViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class BaseCellViewModel<Param, View: UITableViewCell>: CellViewModel {

    public var param: Param?
    public var slideActions: [UIContextualAction]?

    required public init() {
        self.param = nil
    }

    public init(param: Param, slideActions: [UIContextualAction]? = nil) {
        self.param = param
        self.slideActions = slideActions
    }

    open func configure(view: View) {

    }

    open func update(view: View, values: [any KeyValue]) {

    }

    open func update(with values: [any KeyValue]) {

    }
}
