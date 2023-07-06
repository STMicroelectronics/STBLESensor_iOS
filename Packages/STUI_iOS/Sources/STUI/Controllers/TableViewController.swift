//
//  TableViewController.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STCore

open class TableViewController<Presenter, View: UIView>: BaseViewController<Presenter, View> {

    public var tableView: UITableView = UITableView()

    open override func configureView() {
        let mainView = makeView()

        view.addSubview(mainView, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor),
            equal(\.safeAreaLayoutGuide.leftAnchor),
            equal(\.safeAreaLayoutGuide.rightAnchor),
            equal(\.safeAreaLayoutGuide.bottomAnchor)
        ])

        self.mainView = mainView

        view.backgroundColor = mainView.backgroundColor

        configureTableView()
    }

    open func configureTableView() {

        tableView.separatorStyle = .none

        mainView.addSubview(tableView, constraints: [
            equal(\.topAnchor),
            equal(\.leftAnchor),
            equal(\.rightAnchor),
            equal(\.bottomAnchor)
        ])

        tableView.backgroundColor = mainView.backgroundColor
    }
}

open class TableNoViewController<Presenter>: BaseNoViewController<Presenter> {

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
