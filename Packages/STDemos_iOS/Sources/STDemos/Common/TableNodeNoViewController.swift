//
//  TableNodeNoViewController.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

open class TableNodeNoViewController<Presenter>: BaseNodeNoViewController<Presenter> {

    public var tableView: UITableView = UITableView()

    open override func configureView() {

        configureTableView()
    }

    open func configureTableView() {

        tableView.separatorStyle = .none

        view.addSubview(tableView, constraints: [
            equal(\.topAnchor),
            equal(\.leftAnchor),
            equal(\.rightAnchor),
            equal(\.bottomAnchor)
        ])

        tableView.backgroundColor = view.backgroundColor
    }
}
