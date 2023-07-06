//
//  DemoListViewController.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import STCore

public final class DemoListViewController: TableNodeNoViewController<DemoListDelegate> {

//    let bottomBarView = UIView()

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.DemoList.Text.title.localized

//        view.addSubview(bottomBarView)
//
//        bottomBarView.activate(constraints: [
//            equal(\.leadingAnchor),
//            equal(\.trailingAnchor),
//            equal(\.bottomAnchor)
//        ])
//
//        bottomBarView.backgroundColor = .white
//        bottomBarView.setDimensionContraints(height: UIDevice.current.hasNotch ? 54.0 + UIDevice.current.safeAreaEdgeInsets.bottom : 54.0)
//
//        let detailButton = UIButton(type: .custom)
//
//        Buttonlayout.standardLight.apply(to: detailButton,
//                                         text: Localizer.DemoList.Action.openDetailPage.localized)
//
//        bottomBarView.addSubview(detailButton, constraints: [
//            equal(\.topAnchor, constant: 7.0),
//            equal(\.centerXAnchor)
//        ])
//
//        detailButton.setDimensionContraints(width: 250.0, height: 40.0)
//
//        detailButton.on(.touchUpInside) { [weak self] _ in
//            self?.presenter.openWebPage()
//        }

        presenter.load()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        view.bringSubviewToFront(bottomBarView)
//        bottomBarView.applyShadow()
    }


    public override func configureView() {
        super.configureView()
    }


    public override func deinitController() {
        presenter.disconnect()
    }

    public override func configureTableView() {

        tableView.separatorStyle = .none

        view.addSubview(tableView, constraints: [
            equal(\.topAnchor),
            equal(\.leftAnchor),
            equal(\.rightAnchor),
            equal(\.bottomAnchor)
        ])

//        tableView.activate(constraints: [
//            equal(\.bottomAnchor, toView: bottomBarView, withAnchor: \.topAnchor)
//        ])

        tableView.backgroundColor = view.backgroundColor
    }

}
